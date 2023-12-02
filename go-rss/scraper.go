package main

import (
	"context"
	"database/sql"
	"log"
	"strings"
	"sync"
	"time"

	"github.com/cjh-cloud/collective/go-rss/internal/database"
	"github.com/google/uuid"
)

func startScraping(
	db *database.Queries,
	concurrency int, // How many go routines to do scraping on
	timeBetweenRequest time.Duration,
) {
	log.Printf("Scraping on %v go routines every %s", concurrency, timeBetweenRequest)
	ticker := time.NewTicker(timeBetweenRequest)

	// following will run immediatly, whereas something like for range <-ticker.C would wait timeBetweenRequest before running first time
	for ; ; <-ticker.C {
		feeds, err := db.GetNextFeedsToFetch(
			context.Background(),
			int32(concurrency),
		)
		if err != nil {
			log.Println("error fetching feeds:", err)
			continue // function should always be running, otherwise we would stop scraping
		}

		wg := &sync.WaitGroup{} // ?
		for _, feed := range feeds {
			wg.Add(1)

			go scrapeFeed(db, wg, feed)
		}
		wg.Wait() // Wait for x calls to Done() eques to range feeds (smort!)
	}
}

func scrapeFeed(db *database.Queries, wg *sync.WaitGroup, feed database.Feed) {
	defer wg.Done()

	_, err := db.MarkFeedAsFetched(context.Background(), feed.ID)
	if err != nil {
		log.Println("Error marking feed as fetched:", err)
		return
	}

	rssFeed, err := urlToFeed(feed.Url)
	if err != nil {
		log.Println("Error fetching feed:", err)
		return
	}

	for _, item := range rssFeed.Channel.Item {
		// log.Println("Found post", item.Title, "on feed", feed.Name)
		description := sql.NullString{}
		if item.Description != "" {
			description.String = item.Description
			description.Valid = true
		}

		pubAt, err := time.Parse(time.RFC1123Z, item.PubDate)
		if err != nil {
			log.Printf("couldn't parse date %v with err %v", item.PubDate, err)
			continue
		}

		_, err = db.CreatePost(context.Background(),
			database.CreatePostParams{
				ID: uuid.New(),
				CreatedAt: time.Now().UTC(),
				UpdatedAt: time.Now().UTC(),
				Title: item.Title,
				Description: description,
				PublishedAt: pubAt,
				Url: item.Link,
				FeedID: feed.ID,
			},
		)
		if err != nil {
			if strings.Contains(err.Error(), "duplicate key") {
				continue
			} // getting the same posts each time it runs
			log.Println("failed to create post:", err)
		}
	}
	log.Printf("Feed %s collected, %v posts found", feed.Name, len(rssFeed.Channel.Item))
}
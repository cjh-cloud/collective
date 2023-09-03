package controllers

import (
	"github.com/cjh-cloud/collective/go-crud/initializers"
	"github.com/cjh-cloud/collective/go-crud/models"
	"github.com/gin-gonic/gin"
)

func PostsCreate (c *gin.Context) {
	// Get data off req body
	var body struct {
		Body string
		Title string
	}

	c.Bind(&body)

	// Create a post
	post := models.Post{Title: body.Title, Body: body.Body}

	DB := initializers.ConnectToDB()

	result := DB.Create(&post)

	if result.Error != nil {
		c.Status(400)
		return
	}

	// Return it
	c.JSON(200, gin.H{
		"post": post,
	})
}

func PostsIndex(c *gin.Context) {
	// Get the posts
	var posts []models.Post
	DB := initializers.ConnectToDB()
	DB.Find(&posts)

	// Respond with them
	c.JSON(200, gin.H {
		"post": posts,
	})
}

func PostsShow(c *gin.Context) {
	// Get id off url
	id := c.Param("id")

	// Get the posts
	var posts []models.Post
	DB := initializers.ConnectToDB()
	DB.First(&posts, id)

	// Respond with them
	c.JSON(200, gin.H {
		"post": posts,
	})
}

func PostsUpdate(c *gin.Context) {
	// Get the id off the url
	id := c.Param("id")

	// Get the data off req body
	var body struct {
		Body string
		Title string
	}

	c.Bind(&body)

	// Find the post were updating
	var post models.Post
	DB := initializers.ConnectToDB()
	DB.First(&post, id)

	// Update it
	DB.Model(&post).Updates(models.Post{
		Title: body.Title,
		Body: body.Body,
	})

	// Respond with it
	c.JSON(200, gin.H {
		"post": post,
	})
}

func PostsDelete(c *gin.Context) {
	// Get the id off the url
	id := c.Param("id")

	// Delete the posts
	DB := initializers.ConnectToDB()
	DB.Delete(&models.Post{}, id)

	// Respond
	c.Status(200)
}

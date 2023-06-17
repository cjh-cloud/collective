import { Injectable, Scope } from "@nestjs/common";

// Scope means that userId is not potentially overwritten by multiple requests, 
// as it would be a singleton by default (one instance for the whole application)
@Injectable({ scope: Scope.REQUEST })
export class RequestService {
    private userId: string;

    setUserId(userId: string) {
        this.userId = userId;
    }

    getUserId() {
        return this.userId;
    }
}
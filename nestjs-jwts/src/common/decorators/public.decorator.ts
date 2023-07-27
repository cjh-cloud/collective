import { SetMetadata } from "@nestjs/common";

// Function to set metadata isPublic to true
export const Public = () => SetMetadata("isPublic", true);
// simple function that returns a promise that will resolve after the timeout we provided
export const sleep = (timeout: number) => {
  return new Promise<void>((resolve) => setTimeout(resolve, timeout));
}
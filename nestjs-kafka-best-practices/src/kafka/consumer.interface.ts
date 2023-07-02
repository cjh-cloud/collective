// interface that all consumers will implement
export interface IConsumer {
  connect: () => Promise<void>; // connect method
  disconnect: () => Promise<void>; // disconnect method
  consume: (onMessage: (message: any) => Promise<void>) => Promise<void> // like a while loop when app starts up
}

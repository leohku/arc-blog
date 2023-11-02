import { kv } from "@vercel/kv";

export default async function Home() {
  const space = (await kv.get("space")) as string;

  return <main>{JSON.stringify(space)}</main>;
}

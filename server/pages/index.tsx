import { kv } from "@vercel/kv";
import { Space } from "@/types/space";
import Head from "next/head";
import ResolvedView from "@/components/ResolvedView";

import type { GetServerSideProps } from "next";

export default function HomePage({ space }: { space: Space }) {
  return (
    <>
      <Head>
        <title>{space.title}</title>
        <meta
          name="description"
          content="My personal blog, built on Arc"
        ></meta>
      </Head>
      <ResolvedView slugArray={["about-me"]} space={space} />
    </>
  );
}

export const getServerSideProps = (async (context) => {
  const space = (await kv.get("space")) as Space;
  return { props: { space } };
}) satisfies GetServerSideProps<{
  space: Space;
}>;

import { kv } from "@vercel/kv";
export type RequestBody = {
  secret_key?: string;
  space?: string;
};

export async function POST(request: Request) {
  const baseResponse = {
    version: "v0.1-beta",
    update: false,
  };

  let reqBody: RequestBody;

  try {
    reqBody = await request.json();
  } catch {
    return new Response(
      JSON.stringify({
        ...baseResponse,
        error: "Malformed request",
      }),
      {
        status: 400,
        headers: {
          "Content-Type": "application/json",
        },
      }
    );
  }

  if (!reqBody.space) {
    return Response.json(baseResponse);
  }

  // TODO: Implement secret key verification

  try {
    await kv.set("space", reqBody.space);
    return Response.json({
      ...baseResponse,
      update: true,
    });
  } catch (error) {
    return Response.json({
      ...baseResponse,
      error: "Error updating KV store",
    });
  }
}

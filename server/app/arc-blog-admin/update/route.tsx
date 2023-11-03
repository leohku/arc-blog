import { kv } from "@vercel/kv";

export async function POST(request: Request) {
  const baseResponse = {
    version: "v0.1-beta",
  };

  let reqBody: ClientRequest;
  let resBody: ServerResponse;

  try {
    reqBody = await request.json();
  } catch {
    resBody = {
      ...baseResponse,
      success: false,
      error: "Malformed request",
    };
    return new Response(JSON.stringify(resBody), {
      status: 400,
      headers: {
        "Content-Type": "application/json",
      },
    });
  }

  if (!reqBody.secret_key || typeof reqBody.secret_key !== "string") {
    resBody = {
      ...baseResponse,
      success: false,
      error: "Invalid secret",
    };
    return Response.json(resBody);
  }

  try {
    const secret_key = await kv.get("secret_key");
    if (secret_key === null || secret_key !== reqBody.secret_key) {
      resBody = {
        ...baseResponse,
        success: false,
        error: "Keys do not match",
      };
      return Response.json(resBody);
    }
  } catch (error) {
    resBody = {
      ...baseResponse,
      success: false,
      error: "Error fetching secret key",
    };
    return Response.json(resBody);
  }

  if (!reqBody.space) {
    resBody = {
      ...baseResponse,
      success: true,
    };
    return Response.json(resBody);
  }

  if (typeof reqBody.space !== "string") {
    resBody = {
      ...baseResponse,
      success: false,
      error: "Invalid space",
    };
    return Response.json(resBody);
  }

  try {
    await kv.set("space", reqBody.space);
    resBody = {
      ...baseResponse,
      success: true,
    };
    return Response.json(resBody);
  } catch (error) {
    resBody = {
      ...baseResponse,
      success: false,
      error: "Error updating KV store",
    };
    return Response.json(resBody);
  }
}

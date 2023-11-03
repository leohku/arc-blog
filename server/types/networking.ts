interface ClientRequest {
  secret_key: string;
  space?: string;
}

interface ServerResponse {
  version: string;
  success: boolean;
  error?: string;
}

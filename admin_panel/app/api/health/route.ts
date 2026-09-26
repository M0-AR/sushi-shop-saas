export async function GET() {
  return Response.json({ status: "ok", service: "sushi-saas-admin", time: new Date().toISOString() });
}

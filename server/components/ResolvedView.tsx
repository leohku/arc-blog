import { SidebarNodeType, Space } from "@/types/space";
import resolve from "@/utils/resolver";

export default function ResolvedView({
  slugArray,
  space,
}: {
  slugArray: string[];
  space: Space;
}) {
  const resolved = resolve(slugArray, space);

  if (!resolved.found) {
    return <main>404</main>;
  }

  if (resolved.result.type === SidebarNodeType.Tab) {
    return (
      <meta http-equiv="refresh" content={`0; URL=${resolved.result.info}`} />
    );
  }

  const middleURL =
    resolved.result.type === SidebarNodeType.ArcDocument ? "p" : "e";

  return (
    <iframe
      src={`https://arc.net/${middleURL}/${resolved.result.info}`}
      style={{
        position: "fixed",
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
        width: "100%",
        height: "100%",
        border: "none",
        margin: 0,
        padding: 0,
        overflow: "hidden",
        zIndex: 999999,
      }}
    >
      Your browser does not support iframes
    </iframe>
  );
}

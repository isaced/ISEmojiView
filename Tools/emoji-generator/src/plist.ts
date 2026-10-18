export type PlistValue = string | PlistValue[] | { [key: string]: PlistValue };

function escapeXML(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

function serializeValue(value: PlistValue, level: number): string {
  const indent = "  ".repeat(level);

  if (typeof value === "string") {
    return `${indent}<string>${escapeXML(value)}</string>`;
  }

  if (Array.isArray(value)) {
    if (value.length === 0) {
      return `${indent}<array/>`;
    }

    const children = value
      .map((child) => serializeValue(child, level + 1))
      .join("\n");

    return `${indent}<array>\n${children}\n${indent}</array>`;
  }

  const entries = Object.entries(value);
  if (entries.length === 0) {
    return `${indent}<dict/>`;
  }

  const children = entries
    .map(([key, child]) => {
      return `${"  ".repeat(level + 1)}<key>${escapeXML(key)}</key>\n${serializeValue(child, level + 1)}`;
    })
    .join("\n");

  return `${indent}<dict>\n${children}\n${indent}</dict>`;
}

export function serializePlist(value: PlistValue, comment?: string): string {
  const commentLine = comment ? `<!-- ${comment} -->\n` : "";

  return `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
${commentLine}<plist version="1.0">
${serializeValue(value, 0)}
</plist>
`;
}

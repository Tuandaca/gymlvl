import os

search_roots = [
    r"d:\Projects",
    r"C:\tools",
    r"C:\Users\tuand\AppData",
    r"C:\Users\tuand\.gemini",
]

found = []
for root in search_roots:
    if not os.path.exists(root):
        continue
    for dirpath, dirnames, filenames in os.walk(root):
        for f in filenames:
            fl = f.lower()
            if fl.endswith('.ttf') or fl.endswith('.otf') or fl.endswith('.woff2'):
                if any(k in fl for k in ['archivo', 'space', 'grotesk', 'mono', 'inter', 'orbitron']):
                    full_path = os.path.join(dirpath, f)
                    found.append((f, full_path, os.path.getsize(full_path)))

for f, p, s in found[:50]:
    print(f"{f} ({s} bytes) -> {p}")
if not found:
    print("None found")

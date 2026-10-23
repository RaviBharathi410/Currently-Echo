import asyncio
import json
import urllib.request
import base64
import os
import websockets

async def capture():
    # 1. Query devtools target
    targets = json.loads(urllib.request.urlopen('http://127.0.0.1:52010/json').read())
    echo_target = None
    for t in targets:
        if t.get('title') == 'ECHO' or '5000' in t.get('url', ''):
            echo_target = t
            break

    if not echo_target:
        print("No ECHO target found:", targets)
        return

    ws_url = echo_target['webSocketDebuggerUrl']
    print("Connecting to ws_url:", ws_url)

    async with websockets.connect(ws_url) as ws:
        # Navigate to /#/test
        nav_req = {
            "id": 1,
            "method": "Page.navigate",
            "params": {"url": "http://localhost:5000/#/test"}
        }
        await ws.send(json.dumps(nav_req))
        resp = await ws.recv()
        print("Nav resp:", resp)

        await asyncio.sleep(2.5)

        # Capture screenshot
        shot_req = {
            "id": 2,
            "method": "Page.captureScreenshot",
            "params": {"format": "png"}
        }
        await ws.send(json.dumps(shot_req))
        resp = await ws.recv()
        data = json.loads(resp)
        img_b64 = data['result']['data']
        img_bytes = base64.b64decode(img_b64)

        out_dir = os.environ.get("REVIEW_DIR", os.path.join("build", "review"))
        os.makedirs(out_dir, exist_ok=True)
        out_path = os.path.join(out_dir, "phase1_flutter_chrome.png")
        with open(out_path, "wb") as f:
            f.write(img_bytes)
        print("Saved screenshot to:", out_path)

if __name__ == '__main__':
    asyncio.run(capture())

# Third-Party Software Notices & Licenses

brūhi Cloud incorporates, bundles, or interoperates with several third-party open-source components, libraries, and utilities. This document provides attribution, copyright notices, and license terms governing those respective third-party components.

---

## Table of Contents

1. [External Audio Streaming Server (Icecast) Interoperability](#1-external-audio-streaming-server-icecast-interoperability)
2. [Audio Processing & Encoding Libraries (LGPL & MPL)](#2-audio-processing--encoding-libraries-lgpl--mpl)
3. [Rust Audio Engine Dependencies](#3-rust-audio-engine-dependencies)
4. [Python Server Dependencies](#4-python-server-dependencies)
5. [Web UI & Icon Dependencies](#5-web-ui--icon-dependencies)
6. [Infrastructure & Reverse Proxy (Caddy) — Apache-2.0](#6-infrastructure--reverse-proxy-caddy--apache-20)
7. [Open Source License Texts](#7-open-source-license-texts)

---

## 1. External Audio Streaming Server (Icecast) Interoperability

brūhi Cloud includes client-side network capabilities to syndicate outbound audio streams to external **Icecast** servers over standard HTTP/TCP sockets.

- **Project:** Icecast Server
- **Copyright:** © 1999–2024 Jack Moffitt, Michael Smith, Karl Heyes, and Xiph.Org Foundation contributors
- **License:** GNU General Public License version 2 (GPLv2)
- **Upstream Source Repository:** [https://gitlab.xiph.org/xiph/icecast-server](https://gitlab.xiph.org/xiph/icecast-server)

*Note on Architecture:* brūhi Cloud does not bundle, build, or distribute Icecast server binaries or containers. Native HLS audio generation is handled internally. Outbound Icecast syndication functions strictly as an independent network client connecting over standard TCP sockets. Under copyright law, arms-length network socket client communication does not extend copyleft obligations to brūhi Cloud's proprietary audio engine or business logic.

---

## 2. Audio Processing & Encoding Libraries (LGPL & MPL)

### FFmpeg
- **Project:** FFmpeg (`ffmpeg`, `libavcodec`, `libavformat`, `libavutil`, `libswresample`)
- **Copyright:** © 2000–2026 the FFmpeg developers
- **License:** GNU Lesser General Public License version 2.1 or later (LGPLv2.1+)
- **Upstream Source:** [https://ffmpeg.org](https://ffmpeg.org)
- **Usage:** Used as a runtime utility for audio container inspection (`ffprobe`) and audio conversion.

### LAME (mp3lame)
- **Project:** LAME MP3 Encoder (`mp3lame-sys`, `mp3lame-encoder`)
- **Copyright:** © 1999–2026 The LAME Project (Mike Cheng, Mark Taylor, et al.)
- **License:** GNU Lesser General Public License version 2.0 or later (LGPLv2.0+)
- **Upstream Source:** [https://lame.sourceforge.io](https://lame.sourceforge.io)
- **Usage:** Dynamically linked by the `bruhi-audio` engine for high-fidelity MP3 stream encoding.

### Symphonia
- **Project:** Symphonia Audio Decoding Library
- **Copyright:** © 2019–2025 Philip Deljanov
- **License:** Mozilla Public License version 2.0 (MPL-2.0)
- **Upstream Source:** [https://github.com/pdeljanov/Symphonia](https://github.com/pdeljanov/Symphonia)
- **Usage:** Audio file container demuxing and decoding within the `bruhi-audio` engine.

### Opus Codec (libopus)
- **Project:** Opus Interactive Audio Codec
- **Copyright:** © 2001–2026 Xiph.Org, Skype Limited, Octasic, Jean-Marc Valin, Timothy B. Terriberry, CSIRO, Gregory Maxwell, Mark Borgerding, Erik de Castro Lopo
- **License:** BSD 3-Clause License
- **Upstream Source:** [https://opus-codec.org](https://opus-codec.org)

---

## 3. Rust Audio Engine Dependencies

The `bruhi-audio` engine utilizes the following open-source crates:

| Crate | License | Copyright / Project |
| :--- | :--- | :--- |
| `tokio` | MIT | © Tokio Contributors |
| `axum` | MIT | © Tokio / Axum Contributors |
| `serde`, `serde_json` | MIT / Apache-2.0 | © Erick Tryzelaar, David Tolnay |
| `clap` | MIT / Apache-2.0 | © Clap Contributors |
| `toml` | MIT / Apache-2.0 | © Alex Crichton, TOML Contributors |
| `tracing`, `tracing-subscriber` | MIT | © Tokio Contributors |
| `byteorder` | MIT / Unlicense | © Andrew Gallant |
| `anyhow` | MIT / Apache-2.0 | © David Tolnay |
| `base64` | MIT / Apache-2.0 | © Alice Maz, Marshall Pierce |
| `async-stream` | MIT | © Tokio Contributors |
| `futures-core` | MIT / Apache-2.0 | © Rust Futures Contributors |
| `notify` | CC0-1.0 / Apache-2.0 | © Félix Saparelli and contributors |
| `symphonia-adapter-libopus` | MIT / Apache-2.0 | © Aaron Schey and contributors |
| `opus` | MIT / Apache-2.0 | © SpaceManiac and audiopus contributors |
| `uuid` | MIT / Apache-2.0 | © UUID Contributors |
| `libc` | MIT / Apache-2.0 | © The Rust Project Developers |

---

## 4. Python Server Dependencies

The brūhi Cloud backend server utilizes the following open-source packages:

| Package | License | Copyright / Maintainer |
| :--- | :--- | :--- |
| `fastapi` | MIT | © Sebastián Ramírez |
| `uvicorn` | BSD-3-Clause | © Encode OSS Ltd. / Tom Christie |
| `python-multipart` | Apache-2.0 | © Andrew Chen Wang |
| `websockets` | BSD-3-Clause | © Aymeric Augustin |
| `aiofiles` | Apache-2.0 | © Tin Tvrtković |
| `requests` | Apache-2.0 | © Kenneth Reitz / Python Software Foundation |
| `httpx`, `httpx2` | BSD-3-Clause / MIT | © Encode OSS Ltd. |
| `numpy` | BSD-3-Clause | © NumPy Developers |
| `aiortc` | BSD-3-Clause | © Jeremy Lainé |
| `boto3` | Apache-2.0 | © Amazon.com, Inc. or its affiliates |
| `psutil` | BSD-3-Clause | © Jay Loden, Dave Daeschler, Giampaolo Rodola |
| `aiosqlite` | MIT | © John Reese |
| `bcrypt` | Apache-2.0 | © The Python Cryptographic Authority |
| `webauthn` | BSD-3-Clause | © Duo Security / Yubico |
| `pytest`, `pytest-asyncio` | MIT | © Holger Krekel and contributors |

---

## 5. Web UI & Icon Dependencies

| Package | License | Attribution / Project |
| :--- | :--- | :--- |
| `svelte` | MIT | © Rich Harris and Svelte contributors |
| `@sveltejs/kit` | MIT | © SvelteKit contributors |
| `vite` | MIT | © Evan You and Vite contributors |
| `tailwindcss` | MIT | © Tailwind Labs, Inc. |
| `@iconify-json/solar` | CC-BY-4.0 / Apache-2.0 | © 480 Design / Solar Icons |
| `@iconify/tailwind4` | MIT | © Vjacheslav Trushkin |
| `@dnd-kit-svelte/*` | MIT | © dnd-kit-svelte contributors |

---

## 6. Infrastructure & Reverse Proxy (Caddy) — Apache-2.0

The Docker deployment stack utilizes **Caddy 2** (`caddy:2.8-alpine`) as the automatic HTTPS reverse proxy.

- **Project:** Caddy Web Server
- **Copyright:** © 2015 Matthew Holt and The Caddy Authors
- **License:** Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
- **Source Code:** [https://github.com/caddyserver/caddy](https://github.com/caddyserver/caddy)

---

## 7. Open Source License Texts

### GNU General Public License, Version 2 (GPLv2)
```
GNU GENERAL PUBLIC LICENSE
Version 2, June 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.

Preamble
The licenses for most software are designed to take away your freedom to share
and change it. By contrast, the GNU General Public License is intended to
guarantee your freedom to share and change free software--to make sure the
software is free for all its users. This General Public License applies to most
of the Free Software Foundation's software and to any other program whose
authors commit to using it.

[Complete GPLv2 text available at https://www.gnu.org/licenses/gpl-2.0.txt]
```

### GNU Lesser General Public License, Version 2.1 (LGPLv2.1)
```
GNU LESSER GENERAL PUBLIC LICENSE
Version 2.1, February 1999

Copyright (C) 1991, 1999 Free Software Foundation, Inc.
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.

[Complete LGPLv2.1 text available at https://www.gnu.org/licenses/lgpl-2.1.txt]
```

### Mozilla Public License, Version 2.0 (MPL-2.0)
```
Mozilla Public License Version 2.0
==================================

1. Definitions
1.1. "Contributor" means each individual or legal entity that creates,
contributes to the creation of, or owns Covered Software.
...
[Complete MPL-2.0 text available at https://www.mozilla.org/MPL/2.0/]
```

### The MIT License
```
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### Apache License, Version 2.0
```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---
*For questions regarding open-source compliance or attribution, contact info@bruhi.in.*

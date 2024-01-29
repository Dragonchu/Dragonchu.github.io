---
title: "vscode-godot-配置"
date: 2024-01-14
draft: false
tags: ["godot4","vscode"]
---

.vscode/lanch.json

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "GDScript Godot",
            "type": "godot",
            "request": "launch",
            "project": "${workspaceFolder}",
            "port": 6007,
            "address": "tcp://127.0.0.1",
            "launch_game_instance": true,
            "launch_scene": false
        }
    ]
}
```

.vscode/settings.json

```json
{
    "godot_tools.editor_path": "/Applications/Godot.app/Contents/MacOS/Godot",
    "godot_tools.gdscript_lsp_server_port": 6005,
}
```

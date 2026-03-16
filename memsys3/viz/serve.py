#!/usr/bin/env python3
"""
Servidor HTTP mínimo para visualizar la memoria de los agentes.
Uso: python serve.py
"""

import http.server
import socketserver
import webbrowser
import os

PORT = 8080

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        return super().end_headers()

if __name__ == '__main__':
    # Servir desde el directorio memory/ para acceder a todos los YAMLs
    script_dir = os.path.dirname(os.path.abspath(__file__))
    memory_dir = os.path.dirname(script_dir)
    os.chdir(memory_dir)

    with socketserver.TCPServer(("", PORT), CORSRequestHandler) as httpd:
        url = f"http://localhost:{PORT}/viz/index.html"
        print(f"🚀 Memory Visualizer running at {url}")
        print(f"📊 Press Ctrl+C to stop")

        # Auto-abre navegador
        webbrowser.open(url)

        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 Server stopped")

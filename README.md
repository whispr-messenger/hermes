# Whisper Messaging Application

Whisper is a real-time messaging application for desktop (Windows/macOS/Linux) built with Electron and a high-performance Elixir/Phoenix backend. Inspired by Telegram, Whisper focuses on privacy, speed, and automatic media moderation using hash-based classification.

## Features

- Modern interface built with React + TailwindCSS in Electron
- Scalable backend using Elixir/Phoenix, Redis, and PostgreSQL
- Intelligent moderation based on perceptual hashing (pHash/dHash) to flag sensitive content
- Ultra-fast communication via WebSockets and Kafka
- Clean, semi-transparent UI inspired by Telegram and Apple Messages

## Project Structure

- `/apps/backend` - Elixir/Phoenix backend
- `/apps/desktop` - Electron frontend with React
- `/config` - Configuration files
- `/scripts` - Build and deployment scripts

## Development

### Backend (Elixir/Phoenix)

```bash
cd apps/backend
mix deps.get
mix ecto.create
mix ecto.migrate
mix phx.server# hermes

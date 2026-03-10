# PTCG Battle Arena API

Ruby on Rails 7 game API powering the PTCG Battle Arena — a Pokemon TCG football card battle game built on the RealFevr Battle Arena engine.

## Stack
- Ruby on Rails 7 API
- MongoDB (via Mongoid)
- Redis + Sidekiq (background jobs)
- JWT authentication via ptcg.world login codes

## Quick Deploy to Railway

1. Fork this repo
2. Connect to Railway → New Service → GitHub Repo
3. Set environment variables (see `.env.example`)
4. Add MongoDB Atlas connection string as `MONGODB_URI`
5. Add Redis (Railway addon)
6. Deploy — Railway auto-detects Rails via nixpacks

## Seed the Pokemon Cards
After first deploy, run in Railway console:
```bash
bundle exec rails db:seed
```
This loads all 16,961 Pokemon cards as GreyCard documents.

## Environment Variables
See `.env.example` for all required variables.

## API Authentication
Players authenticate via ptcg.world login codes:
```
POST /v1/auth/ptcg_code
Body: { "code": "847291" }
Returns: { "token": "jwt...", "user": {...} }
```

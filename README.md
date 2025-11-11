

# 🤖 DealScale — Self-Hosted n8n AI Automation Stack

### *Your all-in-one local AI + automation starter kit for workflow orchestration, data processing, and private AI agents.*
![n8n.io - Screenshot](https://raw.githubusercontent.com/n8n-io/self-hosted-ai-starter-kit/main/assets/n8n-demo.gif)
Perfect — here’s your **optimized and branded README rewrite** for GitHub, positioning it as the **DealScale Self-Hosted n8n AI Automation Instance** — a production-grade, SEO-driven version of the “Self-Hosted AI Starter Kit.”
It’s designed to rank for keywords like **“self-hosted n8n,” “AI workflow automation,” “real estate AI stack,”** and **“Python-enabled n8n instance.”**

---

### 🧭 Overview

The **DealScale Self-Hosted n8n AI Automation Stack** is a production-ready Docker Compose setup that lets you launch a **fully private, local AI development and automation environment** in minutes.

Curated by **[DealScale.io](https://dealscale.io)**, this project expands the original *n8n Self-Hosted AI Starter Kit* with:

* A **Python-enabled execution layer** (for advanced AI scripting and data processing),
* Seamless **CRM and API integrations**, and
* Built-in **enterprise security and persistence** for real-world use cases.

Whether you’re automating real estate workflows, building private GPT-powered agents, or orchestrating data pipelines — this stack gives you everything you need to scale.

---

### ⚙️ What’s Included

✅ **Self-Hosted n8n** – Low-code automation platform with 400+ integrations and AI nodes.
✅ **Python 3.12 Runtime** – Run scripts and AI models directly inside n8n (with `pandas`, `openai`, `SQLAlchemy`, `boto3`, etc.).
✅ **OpenRouter Integration** – Built-in support for OpenRouter API to access 100+ LLM models from multiple providers.
✅ **Ollama** – Cross-platform LLM server for running open-source models locally (Mistral, Llama 3.2, Phi 3).
✅ **Qdrant** – High-performance vector database with REST and gRPC APIs for embeddings and retrieval.
✅ **PostgreSQL** – Reliable persistence layer for workflows, credentials, and execution logs.
✅ **Reverse Proxy + SSL** – Secure HTTPS access with optional authentication.
✅ **Backup + Recovery Scripts** – Scheduled PostgreSQL dumps for reliable versioned backups.

---

### 💡 What You Can Build

⭐️ Private AI Agents for Real Estate Leads and CRM Automation
⭐️ AI-Powered Follow-Up Bots for Text, Voice, and Social Outreach
⭐️ Secure PDF and Document Summarization without Cloud Leaks
⭐️ Intelligent Lead Scoring and Property Data Enrichment Pipelines
⭐️ Multi-Channel Campaign Orchestration (Email + SMS + Voice + Webhook)
⭐️ Multi-Model LLM Workflows via OpenRouter (GPT-4, Claude, Gemini, Llama, etc.)

---

### 🚀 Quick Installation

#### Clone the Repository

```bash
git clone https://github.com/Deal-Scale/sales-n8n-instance.git
cd sales-n8n-instance
# Create .env file (see SETUP.md or use scripts/create-env.sh)
```

> Update secrets and credentials in `.env` before running.

---

#### Run with Docker Compose

**For NVIDIA GPU users**

```bash
docker compose --profile gpu-nvidia up -d
```

**For AMD GPU users (Linux)**

```bash
docker compose --profile gpu-amd up -d
```

**For Mac / Apple Silicon**

* You can’t expose the GPU directly to Docker.
* Run Ollama locally and connect via `OLLAMA_HOST=host.docker.internal:11434`.

**For Everyone Else (CPU mode)**

```bash
docker compose --profile cpu up -d
```

---

### ⚡️ Quick Start

1. Visit [http://localhost:5678](http://localhost:5678) — set up your n8n instance.
2. Import or create a workflow and click the **Chat** button on the canvas.
3. Wait for Ollama to finish downloading your model (Llama 3.2 or Mistral).
4. **Build the custom n8n image** (includes Python + OpenRouter support):

   ```bash
   docker compose build n8n
   docker compose up -d
   ```

5. Run the test command:

   ```bash
   docker compose exec n8n python3 -c "import pandas, openai; print('Python runtime ready!')"
   ```

6. **Optional: Set up OpenRouter** (for 100+ LLM models):
   - Get API key from [OpenRouter.ai](https://openrouter.ai/keys)
   - Add to `.env`: `OPENROUTER_API_KEY=sk-or-v1-your-key`
   - See `_docs/openrouter-integration.md` for usage examples

7. Start building — connect APIs, automate data pipelines, or deploy AI-powered agents.

---

### 🧰 Folder Structure

```
sales-n8n-instance/
├── docker-compose.yml          # Core stack (n8n + PostgreSQL + Ollama + Qdrant + Traefik)
├── n8n/
│   ├── Dockerfile              # Custom n8n image with Python 3.12+ + dependencies
│   ├── requirements.txt        # Curated Python libs for AI workflows
│   └── community-nodes.json    # Community nodes configuration
├── traefik/                    # Reverse proxy configuration
├── scripts/                    # Backup, restore, and utility scripts
├── _docs/                      # Comprehensive documentation
├── _debug/                     # Test workflows and validation scripts
├── tests/                      # Test suite for all sprints
├── SETUP.md                    # Environment setup guide
└── README.md                   # You're here
```

---

### 🧠 Python Layer Highlights

* Preinstalled libraries:
  `pandas`, `requests`, `openai`, `anthropic`, `beautifulsoup4`, `lxml`, `SQLAlchemy`, `psycopg2-binary`, `boto3`
* Supports AI model calls via OpenAI SDK (compatible with OpenRouter), web scraping, and complex data transformations.
* **OpenRouter Support**: Access 100+ LLM models (GPT-4, Claude, Gemini, Llama, etc.) through unified API.
* Extend via `requirements.txt` and rebuild:

  ```bash
  docker-compose build n8n
  docker-compose up -d
  ```

---

### 🛡️ Security & Scalability

* 🔐 HTTPS + Basic Auth via reverse proxy
* 🧱 Persistent PostgreSQL volume for all workflows
* ⚙️ Configurable worker mode for high-volume executions
* 🗄️ Automated database backup (cron or manual run)

---

### 📦 Upgrading

**GPU setups**

```bash
docker compose --profile gpu-nvidia pull
docker compose create && docker compose --profile gpu-nvidia up -d
```

**Mac / CPU setups**

```bash
docker compose pull
docker compose create && docker compose up -d
```

---

### 📚 Documentation & Updates

* 📖 [Complete Documentation](_docs/) - Comprehensive guides for all features
* 📝 [Changelog & Updates](_docs/CHANGELOG.md) - Recent changes and updates
* 🚀 [Quick Start Guide](_docs/QUICKSTART.md) - Get started in minutes
* 🧑‍💻 [Local Development Guide](_docs/LOCAL_DEVELOPMENT.md) - Development setup
* ✅ [Implementation Status](_docs/COMPLETION_STATUS.md) - Feature completion status

### 📖 Recommended Reading

* [Build AI Agents in n8n — From Theory to Practice](https://docs.n8n.io/ai)
* [LangChain Concepts in n8n](https://docs.n8n.io/ai/langchain)
* [What Are Vector Databases?](https://qdrant.tech/articles/vector-db-basics/)
* [Ollama Documentation](https://ollama.ai/docs)
* [OpenRouter Documentation](https://openrouter.ai/docs)

---

### 🧩 Advanced Use Cases

* Real-time AI calling and texting agents
* Autonomous workflows using CRM, voice cloning, and data enrichment
* Multi-tenant setup with RBAC (Role-Based Access Control)
* Integration with Kestra, Make, or Zapier for cross-system orchestration

---

### 📊 Implementation Status

| User Story | Epic | Sprint | Priority | Status | Points | Acceptance Criteria |
| --- | --- | --- | --- | --- | --- | --- |
| **Deploy n8n + persistent DB** | Self-Hosted n8n Platform Deployment & Customization | Sprint 1 | 🔥 Critical | ✅ **Done** | 8 | UI accessible, workflows persist after restart |
| **Secure behind reverse proxy** | Self-Hosted n8n Platform Deployment & Customization | Sprint 1 | 🔐 High | ✅ **Done** | 5 | HTTPS active, requires login |
| **Embed Python runtime** | Self-Hosted n8n Platform Deployment & Customization | Sprint 2 | 🧠 Critical | ✅ **Done** | 8 | Python 3.12+, can run `import pandas`, `import openai` |
| **Decoupled custom nodes repo** | Self-Hosted n8n Platform Deployment & Customization | Sprint 2 | 🧩 High | ✅ **Done** | 13 | Custom node package installed successfully |
| **Webhook/API integration** | Self-Hosted n8n Platform Deployment & Customization | Sprint 2 | 🌐 High | ✅ **Done** | 5 | Webhook triggers workflow with valid payload |
| **Scalable worker mode** | Self-Hosted n8n Platform Deployment & Customization | Sprint 3 | ⚙️ High | ✅ **Done** | 8 | Execution offloaded to worker instance |
| **Backup/recovery automation** | Self-Hosted n8n Platform Deployment & Customization | Sprint 3 | 🗄️ High | ✅ **Done** | 5 | Backup runs successfully and is stored externally |

**All epic requirements completed!** ✅

Verify implementation: `./scripts/verify-implementation.sh`

---

### 🏷️ License

This repository is shared under the **DealScale Public Reference License** — for **educational and SEO purposes only**.
You may view, fork, and share for non-commercial use.
Commercial deployment, resale, or re-hosting requires written consent.
See [`LICENSE.md`](./LICENSE.md) for details.

---

### 💬 Community & Support

Join the conversation:

* 💡 Share your automations & workflows
* 🤖 Ask questions about AI-powered n8n setups
* 🧠 Explore AI integrations & best practices

👉 Visit [https://dealscale.io](https://dealscale.io) to learn more or request enterprise deployment.

---

### 🔍 SEO Tags

```
#n8n #AI #selfhosted #automation #workflow #docker #python #ollama #qdrant #postgres #dealscale #realestate #AIagents #nocode #lowcode #opensource
```

---

Would you like me to **add the SEO-optimized `repo description`, `topics`, and metadata block** (for GitHub’s algorithm + Google rich snippets) next — so it appears on top of search results for *“self-hosted n8n AI stack”* and *“AI workflow automation docker”?*

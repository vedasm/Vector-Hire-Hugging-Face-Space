FROM python:3.11-slim

WORKDIR /app

RUN mkdir -p data
RUN mkdir -p /app/.streamlit

COPY requirements.txt .
RUN pip install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir -r requirements.txt

ENV STREAMLIT_SERVER_ENABLE_XSRF_PROTECTION=false
ENV STREAMLIT_SERVER_MAX_UPLOAD_SIZE=200
ENV SENTENCE_TRANSFORMERS_HOME=/app/models

RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')"

COPY app.py main.py ./
COPY data/ ./data/
COPY .streamlit/config.toml /app/.streamlit/config.toml

RUN useradd -m -u 1000 appuser && chown -R appuser /app
USER appuser

EXPOSE 7860

HEALTHCHECK CMD curl --fail http://localhost:7860/_stcore/health || exit 1

CMD ["streamlit", "run", "app.py", \
     "--server.port=7860", \
     "--server.address=0.0.0.0", \
     "--server.headless=true"]
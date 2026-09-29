FROM python:3.12-slim AS engine-build
RUN apt-get update && apt-get install -y --no-install-recommends g++ && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY engine/engine.cpp ./
RUN g++ -std=c++17 -Wall -Wextra -Werror -O2 -fPIC -shared engine.cpp -o libtradecraft_engine.so

FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt && useradd --create-home --uid 10001 appuser
COPY --from=engine-build /src/libtradecraft_engine.so /app/build/libtradecraft_engine.so
COPY backend ./backend
COPY content ./content
COPY gunicorn.conf.py ./
USER appuser
EXPOSE 10000
CMD ["gunicorn", "--config", "gunicorn.conf.py", "backend.app:create_app()"]

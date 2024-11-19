# Fudo
Rack API en Ruby. Test técnico para Fudo.

## Descripción
Esta API está desarrollada con **Rack** siguiendo la especificación de **OpenAPI**. Proporciona endpoints para gestionar productos y expone archivos estáticos (`openapi.yaml` y `AUTHORS`)

## Requisitos Previos
- **Ruby**: Versión `>= 2.7`.
- **Bundler**: Para gestionar las dependencias.
  ```bash
  gem install bundler
  ```

## Instalación
1. Clona este repositorio:
   ```bash
   git clone git@github.com:Manuel-IA/fudo.git
   cd api
   ```

2. Instala las dependencias:
   ```bash
   bundle install
   ```

3. Verifica que los archivos necesarios estén presentes:
   - **`AUTHORS`**: Contiene nombre y apellido del autor.
   - **`openapi.yaml`**: Contiene la especificación de la API.

## Levantar el Proyecto
1. Inicia el servidor con `rackup`:
   ```bash
   rackup config.ru
   ```

2. El servidor estará disponible en:
   ```
   http://localhost:9292
   ```

## Endpoints Disponibles

### 1. Crear Producto
- **Método:** `POST`
- **Ruta:** `/products`
- **Descripción:** Crea un producto de forma asíncrona (disponible después de 5 segundos).
- **Parámetros:**
  - `id`: Identificador único del producto.
  - `name`: Nombre del producto.
- **Ejemplo de solicitud:**
  ```bash
  curl -X POST http://localhost:9292/products \
    -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiZXhwIjoxNzMxOTc5NjQ1fQ hLvMMYfJ8J0v4zDV-p0X-bcKikquypYMNO3V0y45078" \
    -d "id=123&name=Product1"
  ```
- **Respuesta:**
  ```json
  {
    "message": "Product creation is in progress",
    "id": "123"
  }
  ```

### 2. Obtener Lista de Productos
- **Método:** `GET`
- **Ruta:** `/products/list`
- **Descripción:** Devuelve la lista de productos creados.
- **Ejemplo de solicitud:**
  ```bash
  curl -X GET http://localhost:9292/products/list \
    -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiZXhwIjoxNzMxOTc5NjQ1fQ hLvMMYfJ8J0v4zDV-p0X-bcKikquypYMNO3V0y45078"
  ```
- **Respuesta:**
  ```json
  {
    "products": [
      { "id": "123", "name": "Product1" }
    ]
  }
  ```

### 3. Archivo `openapi.yaml`
- **Método:** `GET`
- **Ruta:** `/openapi.yaml`
- **Descripción:** Devuelve la especificación OpenAPI de la API.
- **Ejemplo de solicitud:**
  ```bash
  curl -X GET http://localhost:9292/openapi.yaml
  ```
- **Notas:**
  - Este archivo **no puede ser cacheado**.

### 4. Archivo `AUTHORS`
- **Método:** `GET`
- **Ruta:** `/AUTHORS`
- **Descripción:** Devuelve el archivo `AUTHORS`, que contiene nombre y apellido del autor.
- **Ejemplo de solicitud:**
  ```bash
  curl -X GET http://localhost:9292/AUTHORS
  ```
- **Notas:**
  - Este archivo **puede ser cacheado por 24 horas**.

## Comportamiento Especial

### 1. Compresión Gzip
- Si incluyes el encabezado `Accept-Encoding: gzip` en tus solicitudes, las respuestas serán comprimidas.
- **Ejemplo:**
  ```bash
  curl -X GET http://localhost:9292/products/list \
    -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiZXhwIjoxNzMxOTc5NjQ1fQ.hLvMMYfJ8J0v4zDV-p0X-bcKikquypYMNO3V0y45078" \
    -H "Accept-Encoding: gzip"
  ```

### 2. Cacheo
- El archivo `AUTHORS` puede ser cacheado por 24 horas.
- El archivo `openapi.yaml` no se cachea.

## Notas

### Autenticación
- Los endpoints protegidos requieren un token JWT válido en el encabezado `Authorization`.
- **Ejemplo:**
  ```bash
  Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6ImFkbWluIiwiZXhwIjoxNzMxOTc5NjQ1fQ.hLvMMYfJ8J0v4zDV-p0X-bcKikquypYMNO3V0y45078
  ```

### Procesamiento Asíncrono
- La creación de productos se procesa en segundo plano y puede tardar hasta 5 segundos en completarse.

## Problemas Comunes

### 1. "Command not found: rackup"
- Asegúrate de tener Rack instalado:
  ```bash
  gem install rack
  ```

### 2. "Permission denied"
- Usa `sudo` si encuentras problemas de permisos.

## Autor
- **Nombre:** Manuel Palacio
- **Email:** manuelpc1720@gmail.com

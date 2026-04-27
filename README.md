⚡ Flash App

  Tu mercado sin bajarte del carro
  Aplicación móvil desarrollada en Flutter para comprar productos de
  supermercado, pagar en línea y recoger sin filas.

------------------------------------------------------------------------

📱 Capturas de pantalla

🔐 Autenticación y catálogo

  -------------------------------------------------------------------------
  Login          Home           Detalle               Carrito
  -------------- -------------- --------------------- ---------------------
  Login con      Catálogo de    Precio en USD         Persistencia local
  roles          productos                            

  -------------------------------------------------------------------------

🛒 Flujo de compra

  Checkout          Pedidos     QR          Worker
  ----------------- ----------- ----------- ----------------------
  Métodos de pago   Historial   Código QR   Panel en tiempo real

------------------------------------------------------------------------

🏗️ Arquitectura

Proyecto basado en Clean Architecture:

    lib/
    ├── config/
    ├── core/
    ├── features/
    │   ├── auth/
    │   ├── products/
    │   ├── cart/
    │   ├── orders/
    │   └── profile/

Capas:

-   Presentation → UI + estado (Riverpod)
-   Domain → lógica de negocio
-   Data → repositorios + APIs
-   External → Supabase, APIs, almacenamiento

------------------------------------------------------------------------

🛠️ Stack Tecnológico

  Categoría    Tecnología
  ------------ -------------------
  Framework    Flutter
  Estado       Riverpod
  Navegación   GoRouter
  Backend      Supabase
  DB           PostgreSQL
  API          Exchange Rate
  Local        SharedPreferences
  UI           Material 3

------------------------------------------------------------------------

✨ Funcionalidades

👤 Cliente

-   Autenticación con Supabase
-   Catálogo por categorías
-   Carrito persistente
-   Checkout (Tarjeta, PSE, Nequi)
-   Historial de pedidos
-   QR para recogida
-   Notificaciones
-   Tema oscuro/claro

🧑‍🔧 Trabajador

-   Gestión de pedidos
-   Flujo de estados
-   Prioridad por tiempo

🛠️ Admin

-   Dashboard
-   Gestión de productos
-   Métricas

------------------------------------------------------------------------

🗄️ Base de datos

Tablas principales:

-   profiles
-   categories
-   products
-   orders
-   order_items

✔ Seguridad con Row Level Security (RLS)

------------------------------------------------------------------------

🔐 Roles

  Rol       Acceso
  --------- -----------------
  Cliente   App completa
  Worker    Gestión pedidos
  Admin     Dashboard

------------------------------------------------------------------------

🚀 Instalación

    git clone https://github.com/TU_USUARIO/flash_app.git
    cd flash_app
    flutter pub get

Configuración

-   Crear proyecto en Supabase
-   Configurar app_constants.dart

    flutter run -d chrome

------------------------------------------------------------------------

🧪 Tests

    flutter test

✔ 21 tests unitarios
✔ Arquitectura testeable

------------------------------------------------------------------------

📋 Decisiones técnicas

-   Supabase > Firebase (relacional)
-   Riverpod > Provider
-   Estado inmutable
-   GoRouter con roles
-   API externa real

------------------------------------------------------------------------

👨‍💻 Autores

-   Dylan Ricaurte
-   Zuley Gomez
-   Brandon Ricaurte
-   Brayan Garcia

🎓 Ingeniería de Software — 2026

------------------------------------------------------------------------

📄 Licencia

Uso académico
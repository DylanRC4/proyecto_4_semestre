# ⚡ Flash App

**Tu mercado sin bajarte del carro** — Aplicación móvil completa desarrollada con Flutter que permite a los usuarios comprar productos de supermercado, pagar en línea y recoger su pedido en autoservicio sin filas ni aglomeraciones.

## 📱 Capturas de pantalla

| Login | Home | Detalle | Carrito |
|-------|------|---------|---------|
| Login con roles (Cliente/Trabajador/Admin) | Catálogo con categorías y productos | Detalle con precio en USD (API externa) | Carrito con persistencia local |

| Checkout | Pedidos | QR Pedido | Panel Worker |
|----------|---------|-----------|--------------|
| Métodos de pago (Tarjeta, PSE, Nequi) | Historial con barra de progreso | Código QR único por pedido | Gestión de pedidos en tiempo real |

## 🏗️ Arquitectura

El proyecto implementa **Clean Architecture** con 3 capas claramente separadas:

lib/
├── config/
│   ├── router/          # GoRouter con redirect por roles
│   └── theme/           # Material Design 3 + tema claro/oscuro
├── core/
│   ├── constants/       # Configuración de la app
│   ├── errors/          # Manejo de errores
│   └── network/         # Servicios (Exchange Rate API, Notificaciones)
└── features/
├── auth/
│   ├── data/
│   │   ├── datasources/    # AuthRemoteDatasource (Supabase)
│   │   └── repositories/   # AuthRepositoryImpl
│   ├── domain/
│   │   ├── repositories/   # AuthRepository (interfaz)
│   │   └── usecases/       # SignIn, SignUp, SignOut
│   └── presentation/
│       ├── providers/      # AuthNotifier (Riverpod)
│       └── screens/        # LoginScreen, RegisterScreen
├── products/
│   ├── data/
│   │   ├── datasources/    # ProductRemoteDatasource
│   │   ├── models/         # ProductModel, CategoryModel
│   │   └── repositories/   # ProductRepositoryImpl
│   ├── domain/
│   │   ├── entities/       # Product, Category
│   │   ├── repositories/   # ProductRepository (interfaz)
│   │   └── usecases/       # GetProducts, GetCategories, GetProductById
│   └── presentation/
│       ├── providers/      # ProductProvider, CategoryProvider
│       └── screens/        # HomeScreen, ProductDetailScreen
├── cart/
│   ├── data/
│   │   └── repositories/   # CartRepositoryImpl (SharedPreferences)
│   ├── domain/
│   │   ├── entities/       # CartItemEntity
│   │   ├── repositories/   # CartRepository (interfaz)
│   │   └── usecases/       # AddToCart
│   └── presentation/
│       ├── providers/      # CartNotifier (estado inmutable)
│       └── screens/        # CartScreen, CheckoutScreen
├── orders/
│   ├── data/
│   │   ├── datasources/    # OrderRemoteDatasource
│   │   └── repositories/   # OrderRepositoryImpl
│   ├── domain/
│   │   ├── repositories/   # OrderRepository (interfaz)
│   │   └── usecases/       # GetOrders, CreateOrder, UpdateOrderStatus
│   └── presentation/
│       ├── providers/      # OrderNotifier
│       └── screens/        # OrdersScreen, OrderDetailScreen, WorkerScreen, AdminScreen
└── profile/
└── presentation/
└── screens/        # ProfileScreen

### Diagrama de capas
┌─────────────────────────────────────────┐
│           PRESENTATION                   │
│   Screens ← Providers (Riverpod)        │
├─────────────────────────────────────────┤
│              DOMAIN                      │
│   UseCases → Repository (interfaces)    │
│              Entities                    │
├─────────────────────────────────────────┤
│               DATA                       │
│   RepositoryImpl → Datasources          │
│                    Models               │
├─────────────────────────────────────────┤
│          EXTERNAL SERVICES               │
│   Supabase (Auth + PostgreSQL + Storage)│
│   Exchange Rate API (tasas de cambio)   │
│   Web Notifications API                 │
│   SharedPreferences (persistencia local)│
└─────────────────────────────────────────┘

## 🛠️ Stack Tecnológico

| Categoría | Tecnología |
|-----------|-----------|
| Framework | Flutter 3.41+ (Dart) |
| State Management | Riverpod 3.x (Notifier API) |
| Navegación | GoRouter con redirect por roles |
| Backend | Supabase (PostgreSQL + REST API + Auth + Storage) |
| API Externa | Exchange Rate API (tasas de cambio COP/USD) |
| Persistencia Local | SharedPreferences |
| Notificaciones | Web Notifications API |
| UI | Material Design 3 con tema personalizado |
| Testing | flutter_test + mocktail patterns |
| QR | qr_flutter |

## ✨ Funcionalidades

### Cliente
- Registro e inicio de sesión con Supabase Auth
- Recuperación de contraseña por email
- Catálogo de productos por categorías (Comida, Aseo, Ropa Adidas)
- Detalle de producto con precio en COP y USD (API externa en tiempo real)
- Carrito de compras con persistencia local (sobrevive al cerrar la app)
- Checkout con métodos de pago (Tarjeta, PSE, Nequi, Pago en tienda)
- Historial de pedidos con barra de progreso
- Código QR único por pedido para recoger en tienda
- Cancelar pedidos (solo pendientes/confirmados)
- Expiración automática de pedidos no confirmados (30 minutos)
- Notificaciones push del navegador por cambio de estado
- Soporte y ayuda integrados
- Tema claro/oscuro con persistencia de preferencia

### Trabajador
- Panel dedicado con vista de pedidos activos
- Información del cliente, hora y antigüedad del pedido
- Flujo de estados: Pendiente → Confirmado → Preparando → Listo → Entregado
- Cancelar pedidos con notificación al cliente
- Contador de pedidos por estado
- Prioridad por antigüedad (pedidos más viejos primero)

### Administrador
- Dashboard con estadísticas (ingresos, pedidos activos, productos, clientes)
- Gestión de productos (activar/desactivar con switch)
- Lista de clientes registrados
- Métricas de pedidos del día

## 🗄️ Base de datos

PostgreSQL en Supabase con las siguientes tablas:

- **profiles** — Datos del usuario (se crea automáticamente al registrarse)
- **categories** — Categorías de productos (Comida, Aseo, Ropa)
- **stores** — Tiendas Flash con ubicación
- **products** — Catálogo con precio, stock, imagen y categoría
- **orders** — Pedidos con estado, total y fecha
- **order_items** — Productos de cada pedido con cantidad y precio unitario

Seguridad implementada con Row Level Security (RLS) en todas las tablas.

## 🔐 Roles y seguridad

| Rol | Acceso | Redirect |
|-----|--------|----------|
| Cliente | Home, productos, carrito, pedidos, perfil | `/home` |
| Trabajador | Panel de gestión de pedidos | `/worker/orders` |
| Admin | Dashboard, productos, clientes | `/admin/orders` |

La autenticación se maneja con Supabase Auth y el routing con GoRouter redirect.

## 🚀 Instalación y ejecución

### Prerrequisitos
- Flutter 3.41 o superior
- Dart SDK
- Chrome (para desarrollo web)
- Cuenta en Supabase (gratuita)

### Pasos

1. Clonar el repositorio:
```bash
git clone https://github.com/TU_USUARIO/flash_app.git
cd flash_app
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Configurar Supabase:
   - Crear proyecto en [supabase.com](https://supabase.com)
   - Ejecutar el SQL de creación de tablas
   - Actualizar URL y anonKey en `lib/core/constants/app_constants.dart`

4. Ejecutar la app:
```bash
flutter run -d chrome
```

5. Ejecutar tests:
```bash
flutter test test/unit/
```

## 🧪 Tests

19 tests unitarios organizados en:

| Archivo | Tests | Cobertura |
|---------|-------|-----------|
| `cart_test.dart` | 3 | CartItemEntity: subtotal, copyWith, default quantity |
| `get_products_test.dart` | 2 | GetProducts: sin filtro, con filtro por categoría |
| `get_categories_test.dart` | 2 | GetCategories: lista completa, orden |
| `auth_test.dart` | 6 | SignIn, SignUp, SignOut con mock repository |
| `cart_domain_test.dart` | 7 | addItem, removeItem, updateQuantity del repositorio |

```bash
flutter test test/unit/
# 00:04 +19: All tests passed!
```

## 📋 Decisiones técnicas

1. **Supabase sobre Firebase**: PostgreSQL relacional con API REST autogenerada, más profesional que Firestore NoSQL para un e-commerce.

2. **Riverpod sobre Provider**: API moderna con Notifier, mejor soporte para testing y dependency injection.

3. **Estado inmutable en Cart**: CartItemEntity usa `copyWith` en vez de mutación directa, siguiendo las mejores prácticas de Riverpod.

4. **GoRouter con redirect**: Manejo centralizado de autenticación y roles sin duplicar lógica en cada pantalla.

5. **API de tasas de cambio**: Demuestra consumo de API REST externa real, con caché de 1 hora para no exceder límites.

6. **Tema claro/oscuro**: Persistido en SharedPreferences, el usuario mantiene su preferencia entre sesiones.

## 👨‍💻 Autor

**Zuley Gomez** — Ingeniería de Software, 4to semestre
**Dylan Ricaurte** — Ingeniería de Software, 4to semestre
**Brandon Ricaurte** — Ingeniería de Software, 4to semestre
**Brayan Garcia** — Ingeniería de Software, 4to semestre


Universitaria de Colombiana — 2026

## 📄 Licencia

Proyecto académico — Aplicaciones para Dispositivos Móviles
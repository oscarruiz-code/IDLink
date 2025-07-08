# 🛡️ IDLink – Plataforma de identidad digital inteligente

**IDLink** es una plataforma moderna y unificada para la gestión de identidades digitales, diseñada para particulares y empresas que buscan una solución segura, escalable y preparada para el futuro del acceso digital.

> 🔐 Centraliza tus accesos.  
> 🤝 Controla identidades en tu empresa.  
> 🌐 Integra el futuro de la Web5 y la descentralización.

---

## 📌 Objetivo

Facilitar la gestión, el uso y la auditoría de accesos digitales mediante una plataforma:

- Multiplataforma (web + móvil)
- Segura por diseño
- Extensible e integrable
- Compatible con tecnologías de identidad emergentes (Passkeys, DID, WebAuthn)

---

## 🧠 Casos de uso

### Para usuarios individuales
- Gestor de accesos personales cifrados
- Login con passkeys y verificación biométrica
- Compartición segura de accesos temporales
- Panel de alertas por accesos sospechosos

### Para organizaciones
- Gestión de usuarios, roles y permisos
- Asignación/revocación de accesos a servicios internos y externos
- Auditorías y logs de actividad en tiempo real
- Integración con SSO y herramientas colaborativas (Google Workspace, GitHub, etc.)

---

## 🧱 Arquitectura técnica

| Componente        | Descripción                                                 |
|------------------|-------------------------------------------------------------|
| `Flutter`         | Frontend multiplataforma (móvil + web)                      |
| `Spring Boot (Kotlin)` | Backend REST API segura, modular y extensible             |
| `Java`            | Motor de análisis de comportamiento y accesos anómalos      |
| `Docker`          | Contenerización y orquestación de microservicios           |
| `Clever Cloud`    | Despliegue cloud escalable y administración de PostgreSQL  |

---

## ⚙️ Tecnologías clave

- Flutter 3.x
- Kotlin + Spring Boot 3.x
- Java 21 (motor de análisis)
- PostgreSQL 15+
- Docker + docker-compose
- Autenticación JWT + cifrado AES256
- Biometría local (`local_auth`) + futura integración WebAuthn/Passkeys

---

## 🚀 Estado del proyecto

> 🧪 Fase: Diseño de MVP y validación técnica

**✅ MVP funcionalidades básicas:**
- [x] Registro/Login seguro
- [x] Gestor de accesos cifrado
- [x] Compartición temporal
- [ ] Roles y permisos para empresas
- [ ] Logs de acceso con IA
- [ ] Despliegue completo en Clever Cloud

---

## 📁 Estructura del repositorio


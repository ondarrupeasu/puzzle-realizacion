> **Este documento NO va del Puzzle de Realización.** Describe `webar.html`, la demo WebAR
> que dio origen al repositorio y que sigue aquí como referencia técnica. Era el antiguo
> `CLAUDE.md` de la raíz, y se movió aquí el 6 oct 2026 al adoptar el Puzzle su propio
> `CLAUDE.md`. No se toca `webar.html` salvo que Alex lo pida.

# webar-sensor-lab

Demo técnica de WebAR con APIs web puras del navegador, sin SDK propietario ni
marcadores. Punto de partida para explorar experiencias de realidad aumentada en
web al estilo de la web AR de Kinder, con foco educativo (ciclo de Realización de
Proyectos Audiovisuales, módulos MTA y DIG) y potencial de producto propio.

**En vivo:** https://ondarrupeasu.github.io/webar-sensor-lab/
**Deploy:** GitHub Pages, rama `main`, root. HTTPS forzado.

## Estado actual

Un único fichero `index.html` (~15,7 KB) autocontenido. Sin build, sin bundler,
sin dependencias locales. Única dependencia externa: Three.js r128 desde CDN.

### Las tres APIs (el núcleo de la demo)

| API | Rol | Notas de implementación |
|-----|-----|------|
| `MediaDevices.getUserMedia()` | Vídeo de cámara de fondo | `facingMode: environment`. Fallback a fondo sintético si falla. |
| `DeviceOrientationEvent` | Giroscopio / IMU (α β γ) | Requiere permiso explícito en iOS 13+. Ver "Lecciones" abajo. |
| WebGL vía Three.js r128 | Render 3D en tiempo real | `CylinderGeometry`/`Sphere`, NO `CapsuleGeometry` (es r142+). |

### Estructura interna de index.html

- **Gate de arranque**: pantalla de portada con botón "Iniciar sensores". El
  permiso de sensores y cámara se piden tras ese gesto (obligatorio por la spec).
- **`startOrientation()`**: pide permiso de orientación, registra listeners,
  instrumenta diagnóstico en pantalla (`#dbg`), aplica fallbacks.
- **`startCamera()`**: abre getUserMedia.
- **Escena Three.js**: tres objetos conmutables por pestaña —
  `ficha` (tarjeta técnica 3D flotante), `voxels` (nube de cubos, efecto
  cubización tipo Kinder), `gridG` (retícula técnica + ejes).
- **Loop de render**: si `sensorLive`, mapea IMU → rotación de escena; si no,
  usa `drag` (arrastre táctil) como fallback.
- **HUD**: viewfinder con esquinas, timecode, telemetría α/β/γ y línea `#dbg`.

## Lecciones técnicas ya resueltas (NO reintroducir estos bugs)

1. **No descartar el evento de orientación por `alpha == null`.** En iOS, `alpha`
   llega null frecuentemente mientras `beta`/`gamma` (los ejes que rotamos) sí
   traen datos. Usar `webkitCompassHeading` como sustituto de alpha para el yaw.

2. **Orden de permisos: orientación ANTES que cámara.** `getUserMedia` suspende
   la ejecución mostrando su diálogo y consume la *transient user activation* del
   gesto. Si `requestPermission()` de orientación se llama después, devuelve
   `denied` sin mostrar diálogo. El handler del botón debe hacer
   `await startOrientation()` y luego `await startCamera()`.

3. **Escuchar `deviceorientation` Y `deviceorientationabsolute`**, sin
   `capture:true`. Algunos navegadores solo emiten el segundo.

4. **Instrumentación en pantalla**: la línea `#dbg` reporta `evt/perm/a/b/g` en
   vivo. Es la herramienta de diagnóstico real en dispositivo; mantenerla o
   evolucionarla, no borrarla.

## Convenciones de trabajo

- **HTTPS obligatorio** para probar: getUserMedia y el permiso de sensores iOS
  exigen contexto seguro. `file://` no sirve. Local: solo desktop (sin cámara iOS).
- **Verificar en lo desplegado, no solo en el repo.** El deploy de Pages puede
  fallar o encolarse de forma transitoria en GitHub Actions dejando en vivo una
  versión antigua. Tras un push, confirmar que el deployment de `github-pages`
  está en estado `success` y que el commit desplegado es el correcto antes de
  dar nada por publicado.
- **Caché**: `raw.githubusercontent.com` cachea vía CDN (Fastly) y puede servir
  versiones viejas; para verificar contenido real, usar la API de contenidos
  (`/contents/index.html`) o Pages ya desplegado con cache-bust (`?v=N`).
- Three.js r128: evitar geometrías de r142+ (`CapsuleGeometry`).
- Mantener el fichero autocontenido salvo decisión explícita de introducir build.

## Direcciones de evolución posibles (sin decidir aún)

- **Anclaje sobre imagen (efecto Kinder real)**: añadir MindAR o AR.js encima de
  esta base para que el 3D se ancle sobre una imagen/marcador impreso en vez de
  flotar libre. MindAR arrastra TensorFlow.js (~10 MB) → romper el
  autocontenido; valorar coste/beneficio.
- **Plantilla reutilizable** para generar experiencias WebAR de aula.
- **Integración con QR / ClapTag** (proyecto propio de claqueta con metadatos AR).

## Perfil del autor (para calibrar respuestas)

Profesional audiovisual con 25+ años (realización, cámara, montaje,
postproducción) y profesor de FP de imagen y sonido. Pensamiento metódico, de
ingeniería. Beginner-friendly en toolchain JS moderno; experto en el dominio
audiovisual. Trato de tú, registro masculino, tono de colega.

Preferencias de trabajo: pensar antes de actuar; leer archivos antes de escribir;
editar solo lo que cambia, no reescribir enteros; no releer lo ya leído salvo
cambio; sin preámbulos ni resúmenes de relleno; testear antes de dar por hecho;
en diagnósticos, verificar presencia activa en el contenido real, nunca concluir
por metadatos o ausencia; si algo es ambiguo, decirlo en vez de rellenar.

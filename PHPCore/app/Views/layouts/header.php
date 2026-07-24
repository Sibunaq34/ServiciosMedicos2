<!doctype html>
<html lang="es">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title><?= e($title ?? 'Servicios Médicos') ?> | Servicios Médicos</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet"
            integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB"
            crossorigin="anonymous">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css" rel="stylesheet">
        <link rel="icon" type="image/svg+xml" href="public/assets/images/favicon.svg">
        <link rel="icon" type="image/x-icon" href="public/assets/images/favicon.ico">
        <link rel="shortcut icon" href="public/assets/images/favicon.ico">
        <link rel="apple-touch-icon" href="public/assets/images/favicon.svg">
        <link href="public/assets/css/app.css" rel="stylesheet">
</head>
<body>
    <?php if (\App\Core\Sesion::estaAutenticado()): ?>
    <?php $usuarioSesion = \App\Core\Sesion::usuario(); ?>
    <?php $currentAction = filter_input(INPUT_GET, 'action') ?: 'index'; ?>

    <div class="app-layout">
        <aside class="app-sidebar d-none d-lg-flex flex-column">
            <div class="sidebar-brand d-flex align-items-center gap-2 px-4 py-3">
                <img src="public/assets/img/logo-servicios-medicos.svg" width="32" height="32" alt="Logo de Servicios Médicos">
                <div>
                    <span class="h6 mb-0 text-white">Servicios Médicos</span>
                </div>
            </div>
            <nav class="sidebar-nav nav nav-pills flex-column px-3 py-3">
                <a class="sidebar-link nav-link <?= $currentAction === 'index' ? 'active' : '' ?>" href="<?= e(url('index')) ?>"><i class="bi bi-house-door-fill me-2"></i>Inicio</a>
                <a class="sidebar-link nav-link <?= $currentAction === 'puestos' ? 'active' : '' ?>" href="<?= e(url('puestos')) ?>"><i class="bi bi-clipboard-data me-2"></i>Puestos</a>
                <a class="sidebar-link nav-link <?= $currentAction === 'oferentes' ? 'active' : '' ?>" href="<?= e(url('oferentes')) ?>"><i class="bi bi-people me-2"></i>Oferentes por Puesto</a>
                <a class="sidebar-link nav-link <?= $currentAction === 'listado-oferentes' ? 'active' : '' ?>" href="<?= e(url('listado-oferentes')) ?>"><i class="bi bi-card-list me-2"></i>Listado de Oferentes</a>
            </nav>
        </aside>

        <div class="offcanvas offcanvas-start app-sidebar offcanvas-sidebar" tabindex="-1" id="sidebarOffcanvas" aria-labelledby="sidebarOffcanvasLabel">
            <div class="offcanvas-header">
                <h5 class="offcanvas-title" id="sidebarOffcanvasLabel">Servicios Médicos</h5>
                <button type="button" class="btn-close text-reset" data-bs-dismiss="offcanvas" aria-label="Cerrar"></button>
            </div>
            <div class="offcanvas-body p-0">
                <nav class="sidebar-nav nav nav-pills flex-column px-3 py-3">
                    <a class="sidebar-link nav-link <?= $currentAction === 'index' ? 'active' : '' ?>" href="<?= e(url('index')) ?>"><i class="bi bi-house-door-fill me-2"></i>Inicio</a>
                    <a class="sidebar-link nav-link <?= $currentAction === 'puestos' ? 'active' : '' ?>" href="<?= e(url('puestos')) ?>"><i class="bi bi-clipboard-data me-2"></i>Puestos</a>
                    <a class="sidebar-link nav-link <?= $currentAction === 'oferentes' ? 'active' : '' ?>" href="<?= e(url('oferentes')) ?>"><i class="bi bi-people me-2"></i>Oferentes por Puesto</a>
                    <a class="sidebar-link nav-link <?= $currentAction === 'listado-oferentes' ? 'active' : '' ?>" href="<?= e(url('listado-oferentes')) ?>"><i class="bi bi-card-list me-2"></i>Listado de Oferentes</a>
                </nav>
            </div>
        </div>

        <div class="app-content">
            <nav class="navbar navbar-light app-topbar shadow-sm">
                <div class="container-fluid d-flex align-items-center justify-content-between">
                    <button class="btn btn-outline-secondary d-lg-none sidebar-toggle" type="button" data-bs-toggle="offcanvas" data-bs-target="#sidebarOffcanvas" aria-controls="sidebarOffcanvas">
                        <i class="bi bi-list"></i>
                    </button>
                    <div class="d-flex align-items-center gap-3 ms-auto user-session-area">
                        <div class="user-avatar-pill">
                            <span class="user-avatar-badge" aria-hidden="true"><i class="bi bi-person-fill"></i></span>
                            <span class="text-truncate text-dark fw-semibold"><?= e($usuarioSesion['nombre_completo'] ?? '') ?></span>
                        </div>
                        <a class="btn btn-link btn-sm text-decoration-none" href="<?= e(url('logout')) ?>">Cerrar sesión</a>
                    </div>
                </div>
            </nav>
            <main class="app-main py-4 py-lg-5">
    <?php else: ?>
            <main class="container py-4 py-lg-5">
    <?php endif; ?>

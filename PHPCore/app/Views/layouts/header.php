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
    <nav class="navbar navbar-dark app-navbar shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-semibold d-flex align-items-center" href="<?= e(url()) ?>">
                <img class="me-2" src="public/assets/img/logo-servicios-medicos.svg" width="36" height="36" alt="">
                <span>Servicios Médicos</span>
            </a>

            <?php if (\App\Core\Sesion::estaAutenticado()): ?>
            <?php $usuarioSesion = \App\Core\Sesion::usuario(); ?>
            <div class="navbar-nav ms-auto flex-row gap-3 align-items-center flex-wrap">
                <span class="navbar-text text-white">
                    <i class="bi bi-person-circle me-1" aria-hidden="true"></i>
                    <?= e($usuarioSesion['nombre_completo'] ?? '') ?>
                    <?php if (($usuarioSesion['nombre_rol'] ?? '') !== ''): ?>
                        · <?= e($usuarioSesion['nombre_rol']) ?>
                    <?php endif; ?>
                </span>
                <a class="nav-link" href="<?= e(url('index')) ?>">Inicio</a>
                <a class="nav-link" href="<?= e(url('puestos')) ?>">Puestos</a>
                <?php if (\App\Core\Sesion::esAdministrador()): ?>
                <a class="nav-link" href="<?= e(url('expedientes')) ?>">Expedientes</a>
                <a class="nav-link" href="<?= e(url('usuarios')) ?>">Usuarios</a>
                <?php endif; ?>
                <a class="nav-link" href="<?= e(url('oferentes')) ?>">Oferentes por Puesto</a>
                <a class="nav-link" href="<?= e(url('listado-oferentes')) ?>">Listado de Oferentes</a>
                <a class="nav-link" href="<?= e(url('logout')) ?>">Cerrar sesión</a>
            </div>
            <?php endif; ?>
        </div>
    </nav>
    
    <main class="container py-4 py-lg-5">

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
                <i class="bi bi-heart-pulse me-2"></i>
                <span>Servicios Médicos</span>
            </a>

            <div class="navbar-nav ms-auto flex-row gap-3">
                <a class="nav-link" href="<?= e(url('index')) ?>">Inicio</a>
                <a class="nav-link" href="<?= e(url('detalle-oferente', ['id' => 1])) ?>">Detalle de Oferente</a>
                <a class="nav-link" href="<?= e(url('crear-empleado', ['idOferente' => 1])) ?>">Crear Empleado</a>
                <a class="nav-link" href="<?= e(url('oferentes')) ?>">Oferentes por Puesto</a>
                <a class="nav-link" href="<?= e(url('listado-oferentes')) ?>">Listado de Oferentes</a>
            </div>
        </div>
    </nav>
    
    <main class="container py-4 py-lg-5">

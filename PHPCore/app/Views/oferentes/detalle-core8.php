<?php
$detalle = is_array($detalle ?? null) ? $detalle : [];
$error = is_string($error ?? null) ? $error : null;
$idOferente = is_int($idOferente ?? null) ? $idOferente : null;
$integracionPendiente = (bool) ($integracionPendiente ?? false);
$mostrarDetalle = !$integracionPendiente && $detalle !== [];

$valor = static function (string $clave) use ($detalle): string {
    $dato = $detalle[$clave] ?? '';

    return is_scalar($dato) ? (string) $dato : '';
};

$lista = static function (string $clave) use ($detalle): array {
    $datos = $detalle[$clave] ?? [];

    return is_array($datos) ? $datos : [];
};
?>

<section class="d-flex flex-column gap-4">
    <div>
        <p class="section-kicker mb-2">CORE8</p>
        <h1 class="h3 mb-1">Detalle completo de oferente</h1>
        <p class="text-secondary mb-0">Consulta de la información registrada para un oferente.</p>
    </div>

    <?php if ($error !== null): ?>
        <div class="alert <?= $integracionPendiente ? 'alert-info' : 'alert-warning' ?>" role="alert">
            <?= e($error) ?>
        </div>
    <?php endif; ?>

    <?php if ($idOferente !== null): ?>
        <div class="alert alert-secondary" role="status">
            ID de oferente solicitado: <strong><?= e((string) $idOferente) ?></strong>
        </div>
    <?php endif; ?>

    <?php if ($mostrarDetalle): ?>
    <div class="row g-4">
        <div class="col-lg-6">
            <article class="card h-100">
                <div class="card-header">Datos básicos</div>
                <div class="card-body">
                    <dl class="row mb-0">
                        <dt class="col-sm-5">Código o ID</dt>
                        <dd class="col-sm-7"><?= e($valor('codigo_oferente')) ?></dd>
                        <dt class="col-sm-5">Identificación</dt>
                        <dd class="col-sm-7"><?= e($valor('identificacion')) ?></dd>
                        <dt class="col-sm-5">Tipo de identificación</dt>
                        <dd class="col-sm-7"><?= e($valor('tipo_identificacion')) ?></dd>
                        <dt class="col-sm-5">Nombre completo</dt>
                        <dd class="col-sm-7"><?= e($valor('nombre_completo')) ?></dd>
                        <dt class="col-sm-5">Fecha de nacimiento</dt>
                        <dd class="col-sm-7"><?= e($valor('fecha_nacimiento')) ?></dd>
                        <dt class="col-sm-5">Fecha de registro</dt>
                        <dd class="col-sm-7 mb-0"><?= e($valor('fecha_registro')) ?></dd>
                    </dl>
                </div>
            </article>
        </div>

        <div class="col-lg-6">
            <article class="card h-100">
                <div class="card-header">Contactos</div>
                <div class="card-body">
                    <h2 class="h6">Correos</h2>
                    <?php if ($lista('correos') === []): ?>
                        <p class="text-secondary">Sin correos para mostrar.</p>
                    <?php else: ?>
                        <ul>
                            <?php foreach ($lista('correos') as $correo): ?>
                                <li><?= e(is_scalar($correo) ? (string) $correo : '') ?></li>
                            <?php endforeach; ?>
                        </ul>
                    <?php endif; ?>

                    <h2 class="h6">Teléfonos</h2>
                    <?php if ($lista('telefonos') === []): ?>
                        <p class="text-secondary mb-0">Sin teléfonos para mostrar.</p>
                    <?php else: ?>
                        <ul class="mb-0">
                            <?php foreach ($lista('telefonos') as $telefono): ?>
                                <li><?= e(is_scalar($telefono) ? (string) $telefono : '') ?></li>
                            <?php endforeach; ?>
                        </ul>
                    <?php endif; ?>
                </div>
            </article>
        </div>

        <div class="col-lg-6">
            <article class="card h-100">
                <div class="card-header">Preparación académica</div>
                <div class="card-body">
                    <?php if ($lista('preparacion_academica') === []): ?>
                        <p class="text-secondary mb-0">Sin preparación académica para mostrar.</p>
                    <?php else: ?>
                        <div class="table-responsive">
                            <table class="table align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th>Institución</th>
                                        <th>Título</th>
                                        <th>Fecha inicial</th>
                                        <th>Fecha final</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($lista('preparacion_academica') as $fila): ?>
                                        <?php $fila = is_array($fila) ? $fila : []; ?>
                                        <tr>
                                            <td><?= e(is_scalar($fila['institucion'] ?? '') ? (string) ($fila['institucion'] ?? '') : '') ?></td>
                                            <td><?= e(is_scalar($fila['titulo'] ?? '') ? (string) ($fila['titulo'] ?? '') : '') ?></td>
                                            <td><?= e(is_scalar($fila['fecha_inicio'] ?? '') ? (string) ($fila['fecha_inicio'] ?? '') : '') ?></td>
                                            <td><?= e(is_scalar($fila['fecha_fin'] ?? '') ? (string) ($fila['fecha_fin'] ?? '') : '') ?></td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php endif; ?>
                </div>
            </article>
        </div>

        <div class="col-lg-6">
            <article class="card h-100">
                <div class="card-header">Experiencia laboral</div>
                <div class="card-body">
                    <?php if ($lista('experiencia_laboral') === []): ?>
                        <p class="text-secondary mb-0">Sin experiencia laboral para mostrar.</p>
                    <?php else: ?>
                        <div class="table-responsive">
                            <table class="table align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th>Empresa</th>
                                        <th>Puesto</th>
                                        <th>Fecha inicial</th>
                                        <th>Fecha final</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($lista('experiencia_laboral') as $fila): ?>
                                        <?php $fila = is_array($fila) ? $fila : []; ?>
                                        <tr>
                                            <td><?= e(is_scalar($fila['empresa'] ?? '') ? (string) ($fila['empresa'] ?? '') : '') ?></td>
                                            <td><?= e(is_scalar($fila['puesto'] ?? '') ? (string) ($fila['puesto'] ?? '') : '') ?></td>
                                            <td><?= e(is_scalar($fila['fecha_inicio'] ?? '') ? (string) ($fila['fecha_inicio'] ?? '') : '') ?></td>
                                            <td><?= e(is_scalar($fila['fecha_fin'] ?? '') ? (string) ($fila['fecha_fin'] ?? '') : '') ?></td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php endif; ?>
                </div>
            </article>
        </div>

        <div class="col-lg-6">
            <article class="card h-100">
                <div class="card-header">Participación</div>
                <div class="card-body">
                    <dl class="row mb-0">
                        <dt class="col-sm-5">Concurso o puesto relacionado</dt>
                        <dd class="col-sm-7 mb-0"><?= e($valor('participacion')) ?></dd>
                    </dl>
                </div>
            </article>
        </div>

        <div class="col-lg-6">
            <article class="card h-100">
                <div class="card-header">Currículum</div>
                <div class="card-body">
                    <p class="text-secondary mb-0">
                        <?= e($valor('curriculum') !== '' ? $valor('curriculum') : 'Sin información segura de currículum para mostrar.') ?>
                    </p>
                </div>
            </article>
        </div>
    </div>
    <?php endif; ?>
</section>

<?php
$detalle = is_array($detalle ?? null) ? $detalle : [];
$error = is_string($error ?? null) ? $error : null;
$idOferente = is_int($idOferente ?? null) ? $idOferente : null;
$mostrarDetalle = $detalle !== [];

$valor = static function (string $clave) use ($detalle): string {
    $dato = $detalle[$clave] ?? '';

    return is_scalar($dato) ? (string) $dato : '';
};

$lista = static function (string $clave) use ($detalle): array {
    $datos = $detalle[$clave] ?? [];

    return is_array($datos) ? $datos : [];
};

$puesto = is_array($detalle['puesto'] ?? null) ? $detalle['puesto'] : null;
$curriculum = is_array($detalle['curriculum'] ?? null) ? $detalle['curriculum'] : null;
?>

<section class="d-flex flex-column gap-4">
    <div>
        <h1 class="h3 mb-1">Detalle de oferente</h1>
        <p class="text-secondary mb-0">Información registrada para la postulación.</p>
    </div>

    <?php if ($error !== null): ?>
        <div class="alert <?= $mostrarDetalle ? 'alert-success' : 'alert-warning' ?>" role="alert">
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
                <div class="card-header">Información personal</div>
                <div class="card-body">
                    <dl class="row mb-0">
                        <dt class="col-sm-5">ID de oferente</dt>
                        <dd class="col-sm-7"><?= e($valor('id_oferente')) ?></dd>
                        <dt class="col-sm-5">Nombre completo</dt>
                        <dd class="col-sm-7"><?= e($valor('nombre_completo')) ?></dd>
                        <dt class="col-sm-5">Fecha de nacimiento</dt>
                        <dd class="col-sm-7 mb-0"><?= e($valor('fecha_nacimiento')) ?></dd>
                    </dl>
                </div>
            </article>
        </div>

        <div class="col-lg-6">
            <article class="card h-100">
                <div class="card-header">Identificación</div>
                <div class="card-body">
                    <dl class="row mb-0">
                        <dt class="col-sm-5">Identificación</dt>
                        <dd class="col-sm-7"><?= e($valor('identificacion')) ?></dd>
                        <dt class="col-sm-5">Tipo</dt>
                        <dd class="col-sm-7 mb-0"><?= e($valor('tipo_identificacion')) ?></dd>
                    </dl>
                </div>
            </article>
        </div>

        <div class="col-lg-6">
            <article class="card h-100">
                <div class="card-header">Correos</div>
                <div class="card-body">
                    <?php if ($lista('correos') === []): ?>
                        <p class="text-secondary mb-0">Sin información registrada.</p>
                    <?php else: ?>
                        <ul class="mb-0">
                            <?php foreach ($lista('correos') as $correo): ?>
                                <li><?= e(is_scalar($correo) ? (string) $correo : '') ?></li>
                            <?php endforeach; ?>
                        </ul>
                    <?php endif; ?>
                </div>
            </article>
        </div>

        <div class="col-lg-6">
            <article class="card h-100">
                <div class="card-header">Teléfonos</div>
                <div class="card-body">
                    <?php if ($lista('telefonos') === []): ?>
                        <p class="text-secondary mb-0">Sin información registrada.</p>
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
                <div class="card-header">Puesto seleccionado</div>
                <div class="card-body">
                    <?php if ($puesto === null): ?>
                        <p class="text-secondary mb-0">Sin puesto asociado.</p>
                    <?php else: ?>
                        <dl class="row mb-0">
                            <dt class="col-sm-5">Código</dt>
                            <dd class="col-sm-7"><?= e((string) ($puesto['codigo_puesto'] ?? '')) ?></dd>
                            <dt class="col-sm-5">Nombre</dt>
                            <dd class="col-sm-7 mb-0"><?= e((string) ($puesto['nombre_puesto'] ?? '')) ?></dd>
                        </dl>
                    <?php endif; ?>
                </div>
            </article>
        </div>

        <div class="col-lg-6">
            <article class="card h-100">
                <div class="card-header">Currículo</div>
                <div class="card-body">
                    <?php if ($curriculum === null): ?>
                        <p class="text-secondary mb-0">Sin currículo registrado.</p>
                    <?php else: ?>
                        <dl class="row mb-0">
                            <dt class="col-sm-5">Archivo</dt>
                            <dd class="col-sm-7"><?= e((string) ($curriculum['nombre_archivo'] ?? '')) ?></dd>
                            <dt class="col-sm-5">Tipo</dt>
                            <dd class="col-sm-7"><?= e((string) ($curriculum['mime'] ?? '')) ?></dd>
                            <dt class="col-sm-5">Tamaño</dt>
                            <dd class="col-sm-7 mb-0"><?= e((string) ($curriculum['tamanio_formateado'] ?? '')) ?></dd>
                        </dl>
                    <?php endif; ?>
                </div>
            </article>
        </div>
    </div>
    <?php endif; ?>
</section>

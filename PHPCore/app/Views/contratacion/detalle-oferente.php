<?php

declare(strict_types=1);

$volver = $codigoPuesto !== ''
    ? url('listado-oferentes', ['codigo_puesto' => $codigoPuesto])
    : url('index');

?>

<section class="oferente-detalle">
    <div class="d-flex flex-column flex-md-row justify-content-between gap-3 align-items-md-center mb-4">
        <div>
            <p class="section-kicker mb-2">Contratación</p>
            <h1 class="h3 mb-1">Detalle de oferente</h1>
        </div>
        <a class="btn btn-outline-secondary" href="<?= e($volver) ?>">Cancelar</a>
    </div>

    <?php if ($mensajeExito): ?>
        <div class="alert alert-success" role="status"><?= e((string) $mensajeExito) ?></div>
    <?php elseif ($mensajeError): ?>
        <div class="alert alert-danger" role="alert"><?= e((string) $mensajeError) ?></div>
    <?php endif; ?>

    <?php if ($error !== null): ?>
        <div class="alert alert-danger" role="alert"><?= e((string) $error) ?></div>
    <?php elseif ($oferente === null): ?>
        <div class="alert alert-warning">No se encontró el oferente solicitado.</div>
    <?php else: ?>
        <?php
        $puesto = is_array($oferente['puesto'] ?? null) ? $oferente['puesto'] : null;
        $curriculum = is_array($oferente['curriculum'] ?? null) ? $oferente['curriculum'] : null;
        $codigoPuestoCreacion = $codigoPuesto !== ''
            ? $codigoPuesto
            : (string) ($puesto['codigo_puesto'] ?? '');
        ?>
        <article class="card mb-4">
            <div class="card-body p-4">
                <h2 class="h4 mb-3"><?= e($oferente['nombre_completo']) ?></h2>
                <dl class="row mb-0">
                    <dt class="col-sm-4">Identificación</dt>
                    <dd class="col-sm-8"><?= e($oferente['identificacion']) ?></dd>
                    <dt class="col-sm-4">Tipo</dt>
                    <dd class="col-sm-8"><?= e($oferente['tipo_identificacion']) ?></dd>
                    <dt class="col-sm-4">Fecha de nacimiento</dt>
                    <dd class="col-sm-8"><?= e($oferente['fecha_nacimiento']) ?></dd>
                </dl>
            </div>
        </article>

        <div class="row g-4 mb-4">
            <div class="col-lg-6">
                <article class="card h-100">
                    <div class="card-header">Correos</div>
                    <ul class="list-group list-group-flush">
                        <?php foreach ($oferente['correos'] as $correo): ?>
                            <li class="list-group-item"><?= e((string) $correo) ?></li>
                        <?php endforeach; ?>
                        <?php if ($oferente['correos'] === []): ?>
                            <li class="list-group-item text-secondary">Sin información registrada.</li>
                        <?php endif; ?>
                    </ul>
                </article>
            </div>
            <div class="col-lg-6">
                <article class="card h-100">
                    <div class="card-header">Teléfonos</div>
                    <ul class="list-group list-group-flush">
                        <?php foreach ($oferente['telefonos'] as $telefono): ?>
                            <li class="list-group-item"><?= e((string) $telefono) ?></li>
                        <?php endforeach; ?>
                        <?php if ($oferente['telefonos'] === []): ?>
                            <li class="list-group-item text-secondary">Sin información registrada.</li>
                        <?php endif; ?>
                    </ul>
                </article>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-lg-6">
                <article class="card h-100">
                    <div class="card-header">Puesto seleccionado</div>
                    <div class="card-body">
                        <?php if ($puesto === null): ?>
                            <p class="text-secondary mb-0">Sin puesto asociado.</p>
                        <?php else: ?>
                            <dl class="row mb-0">
                                <dt class="col-sm-4">Código</dt>
                                <dd class="col-sm-8"><?= e((string) ($puesto['codigo_puesto'] ?? '')) ?></dd>
                                <dt class="col-sm-4">Nombre</dt>
                                <dd class="col-sm-8 mb-0"><?= e((string) ($puesto['nombre_puesto'] ?? '')) ?></dd>
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
                                <dt class="col-sm-4">Archivo</dt>
                                <dd class="col-sm-8"><?= e((string) ($curriculum['nombre_archivo'] ?? '')) ?></dd>
                                <dt class="col-sm-4">Tipo</dt>
                                <dd class="col-sm-8"><?= e((string) ($curriculum['mime'] ?? '')) ?></dd>
                                <dt class="col-sm-4">Tamaño</dt>
                                <dd class="col-sm-8 mb-0"><?= e((string) ($curriculum['tamanio_formateado'] ?? '')) ?></dd>
                            </dl>
                        <?php endif; ?>
                    </div>
                </article>
            </div>
        </div>

        <?php if ($yaEsEmpleado && !$mensajeExito && !$mensajeError): ?>
            <div class="alert alert-info">Este oferente ya fue convertido en empleado.</div>
        <?php elseif ($codigoPuestoCreacion !== ''): ?>
            <form method="post" action="<?= e(url('crear-empleado')) ?>"
                  onsubmit="this.querySelector('button[type=submit]').disabled=true">
                <input type="hidden" name="_csrf" value="<?= e($csrfToken) ?>">
                <input type="hidden" name="id_oferente" value="<?= e((string) $oferente['id_oferente']) ?>">
                <input type="hidden" name="codigo_puesto" value="<?= e($codigoPuestoCreacion) ?>">
                <div class="d-flex gap-2">
                    <button class="btn btn-primary" type="submit">Crear empleado</button>
                    <a class="btn btn-outline-secondary" href="<?= e($volver) ?>">Cancelar</a>
                </div>
            </form>
        <?php else: ?>
            <div class="alert alert-warning">No se recibió el puesto del listado; la creación está deshabilitada.</div>
        <?php endif; ?>
    <?php endif; ?>
</section>

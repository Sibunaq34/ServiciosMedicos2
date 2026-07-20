<?php

declare(strict_types=1);

$volver = $codigoPuesto !== ''
    ? url('listado-oferentes', ['codigo_puesto' => $codigoPuesto])
    : url('index');

$valor = static function (array $fila, string $campo): string {
    return (string) ($fila[$campo] ?? $fila[ucfirst($campo)] ?? '');
};
?>

<section class="oferente-detalle">
    <div class="d-flex flex-column flex-md-row justify-content-between gap-3 align-items-md-center mb-4">
        <div>
            <p class="section-kicker mb-2">Contratación</p>
            <h1 class="h3 mb-1">Detalle de oferente</h1>
            <p class="text-secondary mb-0">Información obtenida mediante CORE8.</p>
        </div>
        <a class="btn btn-outline-secondary" href="<?= e($volver) ?>">Cancelar</a>
    </div>

    <?php if ($mensajeExito): ?>
        <div class="alert alert-success" role="status"><?= e((string) $mensajeExito) ?></div>
    <?php endif; ?>

    <?php if ($mensajeError): ?>
        <div class="alert alert-danger" role="alert"><?= e((string) $mensajeError) ?></div>
    <?php endif; ?>

    <?php if ($error !== null): ?>
        <div class="alert alert-danger" role="alert"><?= e((string) $error) ?></div>
    <?php elseif ($oferente === null): ?>
        <div class="alert alert-warning">No se encontró el oferente solicitado.</div>
    <?php else: ?>
        <article class="card mb-4">
            <div class="card-body p-4">
                <h2 class="h4 mb-3"><?= e($oferente['nombreCompleto']) ?></h2>
                <dl class="row mb-0">
                    <dt class="col-sm-4">Identificación</dt>
                    <dd class="col-sm-8"><?= e($oferente['identificacion']) ?></dd>
                    <dt class="col-sm-4">Tipo</dt>
                    <dd class="col-sm-8"><?= e($oferente['tipoIdentificacion']) ?></dd>
                    <dt class="col-sm-4">Fecha de nacimiento</dt>
                    <dd class="col-sm-8"><?= e($oferente['fechaNacimiento']) ?></dd>
                    <dt class="col-sm-4">Fecha de registro</dt>
                    <dd class="col-sm-8"><?= e($oferente['fechaRegistro']) ?></dd>
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

        <article class="card mb-4">
            <div class="card-header">Preparación académica</div>
            <div class="table-responsive">
                <table class="table mb-0">
                    <thead><tr><th>Institución</th><th>Título</th><th>Inicio</th><th>Fin</th></tr></thead>
                    <tbody>
                    <?php foreach ($oferente['preparacionAcademica'] as $fila): ?>
                        <tr>
                            <td><?= e($valor($fila, 'NombreInstitucion')) ?></td>
                            <td><?= e($valor($fila, 'Titulo')) ?></td>
                            <td><?= e($valor($fila, 'FechaInicio')) ?></td>
                            <td><?= e($valor($fila, 'FechaFin')) ?></td>
                        </tr>
                    <?php endforeach; ?>
                    <?php if ($oferente['preparacionAcademica'] === []): ?>
                        <tr><td colspan="4" class="text-secondary">Sin información registrada.</td></tr>
                    <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </article>

        <article class="card mb-4">
            <div class="card-header">Experiencia laboral</div>
            <div class="table-responsive">
                <table class="table mb-0">
                    <thead><tr><th>Empresa</th><th>Puesto</th><th>Inicio</th><th>Fin</th></tr></thead>
                    <tbody>
                    <?php foreach ($oferente['experienciaLaboral'] as $fila): ?>
                        <tr>
                            <td><?= e($valor($fila, 'NombreEmpresa')) ?></td>
                            <td><?= e($valor($fila, 'PuestoDesempenado')) ?></td>
                            <td><?= e($valor($fila, 'FechaInicio')) ?></td>
                            <td><?= e($valor($fila, 'FechaFin')) ?></td>
                        </tr>
                    <?php endforeach; ?>
                    <?php if ($oferente['experienciaLaboral'] === []): ?>
                        <tr><td colspan="4" class="text-secondary">Sin información registrada.</td></tr>
                    <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </article>

        <article class="card mb-4">
            <div class="card-header">Concursos</div>
            <div class="table-responsive">
                <table class="table mb-0">
                    <thead><tr><th>Código</th><th>Concurso</th><th>Estado</th><th>Asignación</th></tr></thead>
                    <tbody>
                    <?php foreach ($oferente['participaciones'] as $fila): ?>
                        <tr>
                            <td><?= e($valor($fila, 'CodigoConcurso')) ?></td>
                            <td><?= e($valor($fila, 'NombreConcurso')) ?></td>
                            <td><?= e($valor($fila, 'Estado')) ?></td>
                            <td><?= e($valor($fila, 'FechaAsignacion')) ?></td>
                        </tr>
                    <?php endforeach; ?>
                    <?php if ($oferente['participaciones'] === []): ?>
                        <tr><td colspan="4" class="text-secondary">Sin información registrada.</td></tr>
                    <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </article>

        <?php if ($yaEsEmpleado): ?>
            <div class="alert alert-info">Este oferente ya fue convertido en empleado.</div>
        <?php elseif ($codigoPuesto !== ''): ?>
            <form method="post" action="<?= e(url('crear-empleado')) ?>"
                  onsubmit="this.querySelector('button[type=submit]').disabled=true">
                <input type="hidden" name="_csrf" value="<?= e($csrfToken) ?>">
                <input type="hidden" name="id_oferente" value="<?= e((string) $oferente['idOferente']) ?>">
                <input type="hidden" name="codigo_puesto" value="<?= e($codigoPuesto) ?>">
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

<?php
$totalRegistros = (int) ($totalRegistros ?? 0);
$paginaActual = (int) ($paginaActual ?? 1);
$totalPaginas = (int) ($totalPaginas ?? 1);
$cantidadMostrada = count($puestos ?? []);
$inicio = $cantidadMostrada > 0 ? (($paginaActual - 1) * 10) + 1 : 0;
$fin = $cantidadMostrada > 0 ? $inicio + $cantidadMostrada - 1 : 0;

$formatearMonto = static function (mixed $monto): string {
    if ($monto === null || $monto === '' || !is_numeric($monto)) {
        return 'No disponible';
    }

    return number_format((float) $monto, 2, ',', ' ');
};
?>

<section class="core6-puestos-page" aria-labelledby="core6-puestos-title">
    <header class="core6-puestos-header card">
        <div class="card-body p-4 p-lg-5 d-flex align-items-start gap-3 gap-md-4">
            <span class="core6-puestos-header-icon" aria-hidden="true">
                <i class="bi bi-briefcase-fill"></i>
            </span>
            <div>
                <h1 id="core6-puestos-title" class="h3 mb-2">Puestos activos</h1>
                <p class="text-secondary mb-0">Seleccione un puesto para consultar los oferentes que cumplen sus requisitos.</p>
            </div>
        </div>
    </header>

    <?php if (!empty($error)): ?>
        <div class="alert alert-warning core6-puestos-alert d-flex gap-3 align-items-start mt-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill" aria-hidden="true"></i>
            <div>
                <strong class="d-block mb-1">No se pudo cargar la información</strong>
                <?= e($error) ?>
            </div>
        </div>
    <?php elseif ($puestos === []): ?>
        <div class="card mt-4">
            <div class="core6-puestos-empty empty-state">
                <span class="empty-icon" aria-hidden="true"><i class="bi bi-briefcase"></i></span>
                <h2 class="h5 mb-2">No hay puestos activos disponibles</h2>
                <p class="text-secondary mb-0">En este momento no se encontraron puestos activos para mostrar.</p>
            </div>
        </div>
    <?php else: ?>
        <div class="core6-puestos-summary mt-4" aria-label="Resumen del listado">
            <div class="core6-summary-item">
                <span class="core6-summary-icon" aria-hidden="true"><i class="bi bi-briefcase"></i></span>
                <div><strong><?= $totalRegistros ?></strong><span>puestos activos</span></div>
            </div>
            <div class="core6-summary-item">
                <span class="core6-summary-icon" aria-hidden="true"><i class="bi bi-files"></i></span>
                <div><strong><?= $paginaActual ?> de <?= $totalPaginas ?></strong><span>página actual</span></div>
            </div>
            <div class="core6-summary-item">
                <span class="core6-summary-icon" aria-hidden="true"><i class="bi bi-list-check"></i></span>
                <div><strong><?= $cantidadMostrada ?></strong><span>mostrados en esta página</span></div>
            </div>
        </div>

        <div class="card mt-4 overflow-hidden">
            <div class="table-responsive core6-puestos-table-wrap">
                <table class="table table-hover core6-puestos-table mb-0">
                    <caption class="visually-hidden">Listado de puestos activos</caption>
                    <thead>
                        <tr>
                            <th scope="col">Código</th>
                            <th scope="col">Puesto</th>
                            <th scope="col">Jefatura</th>
                            <th scope="col" class="text-end">Monto salarial</th>
                            <th scope="col">Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                    <?php foreach ($puestos as $puesto): ?>
                        <tr>
                            <td data-label="Código"><span class="core6-puesto-code"><?= e($puesto['codigoPuesto']) ?></span></td>
                            <td data-label="Puesto">
                                <a class="core6-puesto-link" href="<?= e(url('listado-oferentes', ['codigo_puesto' => $puesto['codigoPuesto']])) ?>">
                                    <span><?= e($puesto['nombrePuesto']) ?></span>
                                    <i class="bi bi-arrow-right" aria-hidden="true"></i>
                                </a>
                            </td>
                            <td data-label="Jefatura">
                                <?= $puesto['jefatura'] !== '' ? e($puesto['jefatura']) : '<span class="text-secondary">Sin jefatura asignada</span>' ?>
                            </td>
                            <td data-label="Monto salarial" class="text-end core6-puesto-salary"><?= e($formatearMonto($puesto['montoSalario'])) ?></td>
                            <td data-label="Estado"><span class="core6-puesto-status"><span aria-hidden="true"></span>Activo</span></td>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <div class="core6-puestos-list-footer">
                <p class="mb-0 text-secondary">Mostrando <?= $inicio ?>&ndash;<?= $fin ?> de <?= $totalRegistros ?> puestos activos</p>
                <?php if ($totalPaginas > 1): ?>
                    <nav class="core6-puestos-pagination" aria-label="Paginación de puestos">
                        <ul class="pagination mb-0">
                            <li class="page-item <?= $paginaActual === 1 ? 'disabled' : '' ?>">
                                <a class="page-link" href="<?= e(url('puestos', ['pagina' => max(1, $paginaActual - 1)])) ?>" <?= $paginaActual === 1 ? 'aria-disabled="true" tabindex="-1"' : '' ?>>Anterior</a>
                            </li>
                            <?php for ($pagina = 1; $pagina <= $totalPaginas; $pagina++): ?>
                                <li class="page-item <?= $pagina === $paginaActual ? 'active' : '' ?>">
                                    <a class="page-link" href="<?= e(url('puestos', ['pagina' => $pagina])) ?>" <?= $pagina === $paginaActual ? 'aria-current="page"' : '' ?>><?= $pagina ?></a>
                                </li>
                            <?php endfor; ?>
                            <li class="page-item <?= $paginaActual === $totalPaginas ? 'disabled' : '' ?>">
                                <a class="page-link" href="<?= e(url('puestos', ['pagina' => min($totalPaginas, $paginaActual + 1)])) ?>" <?= $paginaActual === $totalPaginas ? 'aria-disabled="true" tabindex="-1"' : '' ?>>Siguiente</a>
                            </li>
                        </ul>
                    </nav>
                <?php endif; ?>
            </div>
        </div>
    <?php endif; ?>
</section>

<?php
/**
 * Vista: Listado de Oferentes (HU CORE7)
 *
 * Variables recibidas desde OferenteController::listadoOferentes():
 *   string|null $error
 *   array       $oferentes     (página actual, máx. 10)
 *   string|null $codigoPuesto
 *   int         $paginaActual
 *   int         $totalPaginas
 *
 * Enlaces pendientes de HU no implementadas todavía:
 *   - 'detalleOferente' -> HU CORE9 (detalle de oferente)
 *   - 'listadoPuestos'  -> HU CORE6 (listado de puestos)
 * Se usan aquí como placeholders con el mismo helper url() del proyecto;
 * cuando esas HU existan, solo hace falta que el 'action' coincida.
 */
?>

<h1>Listado de Oferentes</h1>

<?php if ($error !== null): ?>
    <div class="alert alert-warning"><?= e($error) ?></div>

<?php else: ?>

    <p>Puesto: <strong><?= e($codigoPuesto) ?></strong></p>

    <?php if (empty($oferentes)): ?>
        <p>No se encontraron oferentes para este puesto.</p>
    <?php else: ?>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Nombre completo</th>
                    <th>Identificación</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($oferentes as $oferente): ?>
                <tr>
                    <td>
                        <a href="<?= e(url('detalle-oferente', [
                            'id' => $oferente['id_oferente'],
                            'codigo_puesto' => $codigoPuesto,
                        ])) ?>">
                            <?= e($oferente['nombre_completo']) ?>
                        </a>
                    </td>
                    <td><?= e($oferente['identificacion']) ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <?php if ($totalPaginas > 1): ?>
        <nav aria-label="Paginación de oferentes">
            <ul class="pagination">
                <?php for ($i = 1; $i <= $totalPaginas; $i++): ?>
                <li class="page-item<?= $i === $paginaActual ? ' active' : '' ?>">
                    <a class="page-link"
                       href="<?= e(url('listadoOferentes', ['codigo_puesto' => $codigoPuesto, 'pagina' => $i])) ?>">
                        <?= $i ?>
                    </a>
                </li>
                <?php endfor; ?>
            </ul>
        </nav>
        <?php endif; ?>

    <?php endif; ?>

<?php endif; ?>

<a href="<?= e(url('listadoPuestos')) ?>" class="btn btn-secondary">Regresar</a>

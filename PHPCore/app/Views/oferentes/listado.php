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
 * El nombre enlaza a 'detalle-oferente' (HU CORE9, ya implementada).
 *
 * Enlace pendiente de HU no implementada todavía:
 *   - 'listadoPuestos' -> HU CORE6 (listado de puestos)
 * Se usa aquí como placeholder con el mismo helper url() del proyecto;
 * cuando esa HU exista, solo hace falta que el 'action' coincida.
 */
?>

<h1>Listado de Oferentes</h1>

<form method="get" action="<?= e(url('listado-oferentes')) ?>" class="row g-2 mb-3">
    <input type="hidden" name="action" value="listado-oferentes">
    <div class="col-auto">
        <label for="codigoPuestoInput" class="visually-hidden">Código del puesto</label>
        <input type="text" class="form-control" id="codigoPuestoInput" name="codigo_puesto"
               placeholder="Código del puesto (ej. GER001)" value="<?= e($codigoPuesto) ?>">
    </div>
    <div class="col-auto">
        <button type="submit" class="btn btn-primary">Buscar</button>
    </div>
</form>

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
                        <a href="<?= e(url('detalle-oferente-core8', ['idOferente' => $oferente['id_oferente']])) ?>">
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
                       href="<?= e(url('listado-oferentes', ['codigo_puesto' => $codigoPuesto, 'pagina' => $i])) ?>">
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

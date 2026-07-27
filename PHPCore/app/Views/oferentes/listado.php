<h1>Listado de Oferentes</h1>

<div class="table-shell">
    <?php if ($error !== null): ?>
        <div class="alert alert-warning"><?= e($error) ?></div>

    <?php else: ?>

        <?php if (empty($oferentes)): ?>
            <p>No se encontraron oferentes.</p>
        <?php else: ?>
            <div class="card shadow-sm border-0">
                <div class="table-responsive">
                    <table class="table table-striped mb-0">
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
                                    ])) ?>">
                                        <?= e($oferente['nombre_completo']) ?>
                                    </a>
                                </td>
                                <td><?= e($oferente['identificacion']) ?></td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>

                <?php if ($totalPaginas > 1): ?>
                <nav class="p-3" aria-label="Paginación de oferentes">
                    <ul class="pagination justify-content-center mb-0">
                        <?php for ($i = 1; $i <= $totalPaginas; $i++): ?>
                        <li class="page-item<?= $i === $paginaActual ? ' active' : '' ?>">
                            <a class="page-link"
                               href="<?= e(url('listado-oferentes', array_filter(['codigo_puesto' => $codigoPuesto, 'pagina' => $i]))) ?>">
                                <?= $i ?>
                            </a>
                        </li>
                        <?php endfor; ?>
                    </ul>
                </nav>
                <?php endif; ?>
            </div>

        <?php endif; ?>

    <?php endif; ?>
</div>

<a href="<?= e(url('puestos')) ?>" class="btn btn-secondary mt-3">Regresar</a>

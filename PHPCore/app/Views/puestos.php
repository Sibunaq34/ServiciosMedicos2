<div class="card shadow-sm border-0">
    <div class="card-header"><h1 class="h4 mb-0">Puestos activos</h1></div>
    <div class="card-body p-0">
        <?php if (!empty($error)): ?>
            <div class="alert alert-warning m-4" role="alert"><?= e($error) ?></div>
        <?php elseif ($puestos === []): ?>
            <div class="empty-state">No hay puestos activos disponibles.</div>
        <?php else: ?>
            <div class="table-responsive"><table class="table table-hover">
                <thead><tr><th>Nombre del puesto</th></tr></thead>
                <tbody>
                <?php foreach ($puestos as $puesto): ?>
                    <tr><td><a class="person-link" href="<?= e(url('listado-oferentes', ['codigo_puesto' => $puesto['codigoPuesto']])) ?>"><?= e($puesto['nombrePuesto']) ?></a></td></tr>
                <?php endforeach; ?>
                </tbody>
            </table></div>
        <?php endif; ?>
    </div>
</div>

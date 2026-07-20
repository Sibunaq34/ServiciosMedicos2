<div class="card shadow-sm border-0 form-shell mx-auto">
    <div class="card-header"><h1 class="h4 mb-0">Consultar puesto</h1></div>
    <div class="card-body">
        <?php if (!empty($error)): ?>
            <div class="alert alert-warning"><?= e((string) $error) ?></div>
        <?php else: ?>
            <dl class="row mb-4">
                <dt class="col-sm-4">Código</dt><dd class="col-sm-8"><?= e($puesto['codigoPuesto'] ?? '') ?></dd>
                <dt class="col-sm-4">Nombre</dt><dd class="col-sm-8"><?= e($puesto['nombrePuesto'] ?? '') ?></dd>
                <dt class="col-sm-4">Descripción</dt><dd class="col-sm-8"><?= e($puesto['descripcion'] ?? '') ?></dd>
                <dt class="col-sm-4">Estado</dt><dd class="col-sm-8"><?= e(ucfirst($puesto['estado'] ?? '')) ?></dd>
            </dl>
        <?php endif; ?>
        <a class="btn btn-secondary" href="<?= e(url('puestos')) ?>">Regresar</a>
    </div>
</div>

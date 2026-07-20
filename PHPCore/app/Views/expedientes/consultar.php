<div class="card shadow-sm border-0">
    <div class="card-header">
        <h1 class="h4 mb-0">Consultar expediente</h1>
    </div>
    <div class="card-body">
        <?php if (!empty($error)): ?>
            <div class="alert alert-warning" role="alert"><?= e((string) $error) ?></div>
        <?php else: ?>
            <dl class="row">
                <dt class="col-sm-4">Número de expediente</dt>
                <dd class="col-sm-8"><?= e($expediente['datos']['numeroExpediente'] ?? '') ?></dd>
                <dt class="col-sm-4">Nombre completo</dt>
                <dd class="col-sm-8"><?= e($expediente['datos']['nombreCompleto'] ?? '') ?></dd>
                <dt class="col-sm-4">Estado</dt>
                <dd class="col-sm-8"><?= e($expediente['datos']['estado'] ?? '') ?></dd>
                <dt class="col-sm-4">Observaciones</dt>
                <dd class="col-sm-8"><?= e($expediente['datos']['observaciones'] ?? '') ?></dd>
            </dl>
        <?php endif; ?>
        <a class="btn btn-secondary" href="<?= e(url('expedientes')) ?>">Regresar</a>
    </div>
</div>

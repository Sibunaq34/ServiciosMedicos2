<div class="card shadow-sm border-0">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h1 class="h4 mb-0">Expedientes personales</h1>
        <a class="btn btn-primary btn-sm" href="<?= e(url('expediente-crear')) ?>">Crear expediente</a>
    </div>
    <div class="card-body">
        <?php if (!empty($error)): ?>
            <div class="alert alert-warning" role="alert"><?= e((string) $error) ?></div>
        <?php elseif (empty($expedientes)): ?>
            <div class="alert alert-info" role="alert">No hay expedientes registrados.</div>
        <?php else: ?>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Número</th>
                            <th>Nombre</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($expedientes as $expediente): ?>
                            <tr>
                                <td><?= e($expediente['numeroExpediente'] ?? '') ?></td>
                                <td><?= e($expediente['nombreCompleto'] ?? '') ?></td>
                                <td><?= e($expediente['estado'] ?? '') ?></td>
                                <td>
                                    <a class="btn btn-outline-secondary btn-sm" href="<?= e(url('expediente-consultar', ['id' => $expediente['id'] ?? 0])) ?>">Consultar</a>
                                    <a class="btn btn-outline-primary btn-sm" href="<?= e(url('expediente-editar', ['id' => $expediente['id'] ?? 0])) ?>">Editar</a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>
</div>

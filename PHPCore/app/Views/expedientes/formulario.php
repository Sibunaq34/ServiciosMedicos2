<div class="card shadow-sm border-0">
    <div class="card-header">
        <h1 class="h4 mb-0"><?= e($modo === 'editar' ? 'Editar expediente' : 'Crear expediente') ?></h1>
    </div>
    <div class="card-body">
        <?php if (!empty($error)): ?>
            <div class="alert alert-danger" role="alert"><?= e((string) $error) ?></div>
        <?php endif; ?>
        <?php if (!empty($exito)): ?>
            <div class="alert alert-success" role="alert"><?= e((string) $exito) ?></div>
        <?php endif; ?>

        <form method="post" action="<?= e($modo === 'editar' ? url('expediente-editar', ['id' => $datos['id'] ?? 0]) : url('expediente-crear')) ?>">
            <input type="hidden" name="_csrf" value="<?= e($csrf ?? '') ?>">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label" for="idUsuario">Usuario</label>
                    <input class="form-control" id="idUsuario" name="idUsuario" type="number" min="1" value="<?= e($datos['idUsuario'] ?? '') ?>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label" for="numeroExpediente">Número de expediente</label>
                    <input class="form-control" id="numeroExpediente" name="numeroExpediente" type="text" maxlength="50" value="<?= e($datos['numeroExpediente'] ?? '') ?>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label" for="nombreCompleto">Nombre completo</label>
                    <input class="form-control" id="nombreCompleto" name="nombreCompleto" type="text" maxlength="150" value="<?= e($datos['nombreCompleto'] ?? '') ?>" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label" for="estado">Estado</label>
                    <input class="form-control" id="estado" name="estado" type="text" value="<?= e($datos['estado'] ?? '') ?>" required>
                </div>
                <div class="col-12">
                    <label class="form-label" for="observaciones">Observaciones</label>
                    <textarea class="form-control" id="observaciones" name="observaciones" maxlength="1000" rows="4"><?= e($datos['observaciones'] ?? '') ?></textarea>
                </div>
            </div>
            <div class="mt-4 d-flex gap-2">
                <button class="btn btn-primary" type="submit">Guardar</button>
                <a class="btn btn-secondary" href="<?= e(url('expedientes')) ?>">Regresar</a>
            </div>
        </form>
    </div>
</div>

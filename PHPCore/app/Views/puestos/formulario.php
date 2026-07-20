<div class="card shadow-sm border-0 form-shell mx-auto">
    <div class="card-header"><h1 class="h4 mb-0"><?= $modo === 'editar' ? 'Editar puesto' : 'Crear puesto' ?></h1></div>
    <div class="card-body">
        <?php if (!empty($error)): ?><div class="alert alert-danger"><?= e((string) $error) ?></div><?php endif; ?>
        <?php if (!empty($exito)): ?><div class="alert alert-success"><?= e((string) $exito) ?></div><?php endif; ?>
        <form method="post" action="<?= e($modo === 'editar' ? url('puestos-editar', ['id' => $datos['id'] ?? 0]) : url('puestos-crear')) ?>">
            <input type="hidden" name="_csrf" value="<?= e($csrf ?? '') ?>">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label" for="codigoPuesto">Código</label>
                    <input class="form-control" id="codigoPuesto" name="codigoPuesto" maxlength="20" pattern="[A-Za-z0-9-]{1,20}" value="<?= e($datos['codigoPuesto'] ?? '') ?>" required>
                </div>
                <div class="col-md-8">
                    <label class="form-label" for="nombrePuesto">Nombre</label>
                    <input class="form-control" id="nombrePuesto" name="nombrePuesto" minlength="2" maxlength="150" value="<?= e($datos['nombrePuesto'] ?? '') ?>" required>
                </div>
                <div class="col-12">
                    <label class="form-label" for="descripcion">Descripción</label>
                    <textarea class="form-control" id="descripcion" name="descripcion" maxlength="500" rows="4"><?= e($datos['descripcion'] ?? '') ?></textarea>
                </div>
                <div class="col-md-4">
                    <label class="form-label" for="estado">Estado</label>
                    <select class="form-select" id="estado" name="estado" required>
                        <option value="activo" <?= ($datos['estado'] ?? 'activo') === 'activo' ? 'selected' : '' ?>>Activo</option>
                        <option value="inactivo" <?= ($datos['estado'] ?? '') === 'inactivo' ? 'selected' : '' ?>>Inactivo</option>
                    </select>
                </div>
            </div>
            <div class="mt-4 d-flex gap-2">
                <button class="btn btn-primary" type="submit">Guardar</button>
                <a class="btn btn-secondary" href="<?= e(url('puestos')) ?>">Regresar</a>
            </div>
        </form>
    </div>
</div>

<?php

declare(strict_types=1);

$idOferente = filter_input(INPUT_GET, 'idOferente', FILTER_UNSAFE_RAW);
// Valida ID sin modificarlo.
$idValido = is_string($idOferente) && preg_match('/^[1-9][0-9]*$/', $idOferente) === 1;
// Activa error de prueba.
$simularError = filter_input(INPUT_GET, 'simularError', FILTER_UNSAFE_RAW) === '1';
?>

<?php // Contenedor principal de CORE3. ?>
<section
    class="crear-empleado"
    data-core3-crear-empleado
    data-oferente-id="<?= e($idValido ? $idOferente : '') ?>"
    data-json-url="public/data/oferentes.json"
    data-detalle-url="<?= e(url('detalle-oferente')) ?>"
    data-simular-error="<?= e($simularError ? '1' : '0') ?>"
>
    <div class="d-flex flex-column flex-md-row justify-content-between gap-3 align-items-md-center mb-4">
        <div>
            <p class="section-kicker mb-2">CORE3</p>
            <h1 class="h3 mb-1">Crear Empleado</h1>
            <p class="text-secondary mb-0">Proceso visual de contratacion basado en el oferente seleccionado.</p>
        </div>
        <a class="btn btn-outline-primary" href="#" data-cancelar-superior>
            <i class="bi bi-arrow-left me-1" aria-hidden="true"></i>
            Cancelar
        </a>
    </div>

    <?php // Estado: parametro invalido. ?>
    <div class="alert alert-danger d-none" role="alert" data-parametro-invalido>
        No se proporciono un oferente valido.
    </div>

    <?php // Estado: cargando datos. ?>
    <div class="alert alert-info d-flex align-items-center gap-2" aria-live="polite" data-estado-carga>
        <span class="spinner-border spinner-border-sm" aria-hidden="true"></span>
        <span>Cargando datos del oferente...</span>
    </div>

    <?php // Estado: error de carga. ?>
    <div class="alert alert-danger d-none" role="alert" data-estado-error>
        No fue posible cargar los datos para crear el empleado.
    </div>

    <?php // Estado: sin resultados. ?>
    <div class="card empty-state d-none" data-estado-vacio>
        <div class="empty-icon mx-auto">
            <i class="bi bi-search" aria-hidden="true"></i>
        </div>
        <h2 class="h5">Sin resultados</h2>
        <p class="text-secondary mb-0">No se encontro informacion para el oferente solicitado.</p>
    </div>

    <?php // Formulario cuando hay oferente. ?>
    <div class="d-none" data-formulario-contenido>
        <div class="card mb-4">
            <div class="card-header">Resumen del oferente seleccionado</div>
            <div class="card-body p-4">
                <div class="row g-3">
                    <div class="col-md-6">
                        <span class="text-secondary small d-block">Nombre completo</span>
                        <strong data-resumen-nombre></strong>
                    </div>
                    <div class="col-md-6">
                        <span class="text-secondary small d-block">Identificacion</span>
                        <strong data-resumen-identificacion></strong>
                    </div>
                    <div class="col-md-6">
                        <span class="text-secondary small d-block">Correo</span>
                        <strong data-resumen-correo></strong>
                    </div>
                    <div class="col-md-6">
                        <span class="text-secondary small d-block">Telefono</span>
                        <strong data-resumen-telefono></strong>
                    </div>
                </div>
            </div>
        </div>

        <form class="card" novalidate data-formulario-empleado>
            <div class="card-header">Datos del empleado</div>
            <div class="card-body p-4">
                <div class="alert alert-success d-none" role="status" aria-live="polite" data-mensaje-exito>
                    Empleado creado correctamente en modo demostracion.
                </div>

                <div class="alert alert-danger d-none" role="alert" data-mensaje-error>
                    No fue posible completar la creacion del empleado.
                </div>

                <?php // Datos solo lectura. ?>
                <h2 class="h5 mb-3">Datos heredados del oferente</h2>
                <div class="row g-3 mb-4">
                    <div class="col-md-6">
                        <label class="form-label" for="empleadoNombre">Nombre completo</label>
                        <input class="form-control" id="empleadoNombre" type="text" disabled data-campo-nombre>
                        <div class="invalid-feedback d-block" data-error-nombre></div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label" for="empleadoIdentificacion">Identificacion</label>
                        <input class="form-control" id="empleadoIdentificacion" type="text" disabled data-campo-identificacion>
                        <div class="invalid-feedback d-block" data-error-identificacion></div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label" for="empleadoCorreo">Correo</label>
                        <input class="form-control" id="empleadoCorreo" type="email" disabled data-campo-correo>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label" for="empleadoTelefono">Telefono</label>
                        <input class="form-control" id="empleadoTelefono" type="text" disabled data-campo-telefono>
                    </div>
                </div>

                <?php // Datos editables. ?>
                <h2 class="h5 mb-3">Datos de contratacion</h2>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label" for="empleadoPuesto">Puesto seleccionado</label>
                        <select class="form-select" id="empleadoPuesto" data-campo-puesto>
                            <option value="">Seleccione un puesto</option>
                        </select>
                        <div class="invalid-feedback d-block" data-error-puesto></div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label" for="fechaContratacion">Fecha de contratacion</label>
                        <input class="form-control" id="fechaContratacion" type="date" data-campo-fecha>
                        <div class="invalid-feedback d-block" data-error-fecha></div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label" for="numeroEmpleado">Numero de empleado simulado</label>
                        <input class="form-control" id="numeroEmpleado" type="text" readonly data-campo-numero>
                        <div class="form-text">Numero provisional para demostracion.</div>
                        <div class="invalid-feedback d-block" data-error-numero></div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label" for="estadoEmpleado">Estado inicial del empleado</label>
                        <select class="form-select" id="estadoEmpleado" data-campo-estado>
                            <option value="">Seleccione un estado</option>
                            <option value="Activo">Activo</option>
                            <option value="En induccion">En induccion</option>
                            <option value="Pendiente de documentos">Pendiente de documentos</option>
                        </select>
                        <div class="invalid-feedback d-block" data-error-estado></div>
                    </div>
                    <div class="col-12">
                        <label class="form-label" for="observacionesEmpleado">Observaciones</label>
                        <textarea class="form-control" id="observacionesEmpleado" rows="3" maxlength="300" data-campo-observaciones></textarea>
                    </div>
                </div>
            </div>
            <div class="card-footer bg-white d-flex flex-column flex-sm-row justify-content-end gap-2">
                <a class="btn btn-outline-secondary" href="#" data-cancelar-formulario>Cancelar</a>
                <button class="btn btn-primary" type="submit" data-boton-confirmar>
                    <span class="spinner-border spinner-border-sm me-1 d-none" aria-hidden="true" data-spinner-confirmar></span>
                    Confirmar creacion
                </button>
            </div>
        </form>
    </div>
</section>

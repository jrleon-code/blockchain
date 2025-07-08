#![no_std]

multiversx_sc::imports!();
multiversx_sc::derive_imports!();

/// Smart contract de evaluación por estrellas.
/// Cada dirección puede votar solo una vez. Las puntuaciones válidas van del 1 al 5.
#[multiversx_sc::contract]
pub trait Valoraciones {
    /// Inicializa el contrato. No necesita parámetros.
    #[init]
    fn init(&self) {}

    /// Permite votar con una puntuación de 1 a 5 estrellas.
    #[endpoint]
    fn votar(&self, puntuacion: u8) {
        let caller = self.blockchain().get_caller();

        // Asegura que la puntuación está en el rango permitido
        require!(puntuacion >= 1 && puntuacion <= 5, "Puntuación inválida");

        // Asegura que el votante no ha votado antes
        require!(!self.ya_votaron(&caller).get(), "Ya has votado");

        // Marca que este votante ya ha votado
        self.ya_votaron(&caller).set(true);

        // Acumula la puntuación total
        self.suma().update(|s| *s += puntuacion as u64);

        // Aumenta el contador de votos
        self.total().update(|t| *t += 1);
    }

    /// Consulta la media de votos (redondeada hacia abajo).
    #[view(getMedia)]
    fn get_media(&self) -> u8 {
        let total = self.total().get();
        if total == 0 {
            return 0;
        }
        let suma = self.suma().get();
        (suma / total) as u8
    }

    /// Almacena la suma total de puntuaciones recibidas
    #[storage_mapper("suma")]
    fn suma(&self) -> SingleValueMapper<u64>;

    /// Almacena el número total de votos recibidos
    #[storage_mapper("total")]
    fn total(&self) -> SingleValueMapper<u64>;

    /// Almacena si una dirección ya ha votado
    #[storage_mapper("ya_votaron")]
    fn ya_votaron(&self, address: &ManagedAddress) -> SingleValueMapper<bool>;
}

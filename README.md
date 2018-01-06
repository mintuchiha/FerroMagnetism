An electron in a magnet has a spin that is associated with the magnetic moment. Ferromagnetism is a phenomenon when a collection of these spins conspire to point each magnetic moment in the same direction. Since magnets lose their magnetic property at higher temperatures, we study how temperature affects the magnetic property.
The Ising model assumes that the interaction between neighboring electrons have an energy that is described by,
	
	$$	E = -J\sum_{<ij>}s_is_j $$

where $E$ is the energy of the system, $J$ is the exchange constant, $s$ is spin and $i, j$ represent all neighboring pairs~\cite{book}. 
	Now, using the Monte Carlo Algorithm we are able to sample the spin flips defined by

$$state=
\begin{cases}
	\Delta E \leq 0~~~ \text{flip}
	\Delta E > 0~~~ \text{flip with probability }e^{-\Delta E/kT}	
\end{cases}$$

where $k$ is the Boltzmann's constant and $T$ is the temperature.
![alt text](https://github.com/mintuchiha/FerroMagnetism/blob/master/animation.gif "FerroMagnetism Animation")
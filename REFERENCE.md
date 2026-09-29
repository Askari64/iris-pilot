### reference for what entity stands for what (for the sake of understanding).

- parcel: A boundary polygon representing an individual plot of land evaluated as a candidate site for a Battery Energy Storage System (BESS).

- substation: A coordinate point representing an electrical grid connection facility, needed because viable battery storage sites must sit close to grid access points.

- peatland: A boundary polygon representing carbon-rich wetland habitat where industrial development is prohibited or subject to ecological compensation. 

- screening_layer: A generic polygon table holding all other secondary planning constraints (such as flood zones or nature reserves), categorized by a layer_name.

- source_run: An ETL execution log that records when external data batches are imported into the system, preserving data provenance and auditability.

- evidence: An audit junction table recording the analytical proof of a parcel evaluation (e.g., intersection area with a peatland, eco-points factor, or distance to a substation), linked directly to parcel and source_run. 
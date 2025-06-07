<?php

namespace Database\Seeders;

use App\Models\Warehouse;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class WarehouseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $warehouses = [
            ['name' => 'Main Warehouse', 'code' => 'MAIN'],
            ['name' => 'Secondary Warehouse', 'code' => 'SEC'],
            ['name' => 'Distribution Center', 'code' => 'DIST'],
        ];

        foreach ($warehouses as $warehouse) {
            Warehouse::firstOrCreate(
                ['code' => $warehouse['code']],
                $warehouse
            );
        }
    }
} 
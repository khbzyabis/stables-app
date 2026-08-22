import { Injectable } from '@nestjs/common';
import { Horse } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreateHorseDto } from './dto/create-horse.dto';

@Injectable()
export class HorsesService {
  constructor(private readonly prisma: PrismaService) {}

  /// All queries below use Prisma's builder — values are bound parameters, so
  /// caller input can never alter the SQL structure.
  listForStable(stableId: string): Promise<Horse[]> {
    return this.prisma.horse.findMany({
      where: { stableId },
      orderBy: { createdAt: 'desc' },
    });
  }

  create(stableId: string, dto: CreateHorseDto): Promise<Horse> {
    return this.prisma.horse.create({
      data: { stableId, ...dto },
    });
  }
}

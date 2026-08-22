import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { Role } from '@prisma/client';

import { Roles } from '../common/decorators/roles.decorator';
import { RolesGuard } from '../common/guards/roles.guard';
import { SupabaseAuthGuard } from '../common/guards/supabase-auth.guard';
import { CreateHorseDto } from './dto/create-horse.dto';
import { HorsesService } from './horses.service';

/// Horses are scoped to a stable. Every route requires a valid Supabase JWT
/// (SupabaseAuthGuard) and a matching membership role (RolesGuard). The default
/// global rate limit applies; the write route adds a tighter per-action bucket.
@Controller({ path: 'stables/:stableId/horses', version: '1' })
@UseGuards(SupabaseAuthGuard, RolesGuard)
export class HorsesController {
  constructor(private readonly horses: HorsesService) {}

  /// Any member of the stable may see its horses (RLS enforces this at the DB
  /// too). Grooms cannot see money, but they can see horses.
  @Get()
  @Roles(Role.admin, Role.trainer, Role.groom, Role.rider)
  list(@Param('stableId') stableId: string) {
    return this.horses.listForStable(stableId);
  }

  /// Admins run the stable; a rider joining brings their own horse.
  @Post()
  @Roles(Role.admin, Role.rider)
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  create(
    @Param('stableId') stableId: string,
    @Body() dto: CreateHorseDto,
  ) {
    return this.horses.create(stableId, dto);
  }
}

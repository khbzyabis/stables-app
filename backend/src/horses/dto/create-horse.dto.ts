import {
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import { HorseStatus } from '@prisma/client';

/// Adding a horse is deliberately minimal: only a name is required. Every field
/// is validated and length-bounded; unknown fields are rejected by the global
/// ValidationPipe (whitelist), so nothing untrusted reaches the query layer.
export class CreateHorseDto {
  @IsString()
  @MinLength(1)
  @MaxLength(80)
  name!: string;

  @IsOptional()
  @IsEnum(HorseStatus)
  status?: HorseStatus;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  statusLine?: string;

  @IsOptional() @IsString() @MaxLength(40) age?: string;
  @IsOptional() @IsString() @MaxLength(60) breed?: string;
  @IsOptional() @IsString() @MaxLength(40) sex?: string;
  @IsOptional() @IsString() @MaxLength(20) height?: string;
  @IsOptional() @IsString() @MaxLength(30) box?: string;
  @IsOptional() @IsString() @MaxLength(2000) notes?: string;
}

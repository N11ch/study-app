import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { hash, verify } from 'argon2';
import { PrismaService } from 'src/prisma.service';

// total ngulang proses auth: 11

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async signUp(email: string, pass: string, role: string) {
    const existingUser = await this.prisma.profiles.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new BadRequestException(
        "The email is already used, you can't use the same email dude",
      );
    }

    // ENKRIPSI PASSWORD TERLEBIH DAHULU!!! INI YANG PALING PENTING!
    const hashedPassword = await hash(pass);

    //! SETIAP PERUBAHAN DI DATABASE HARUS ADA DISINI JUGA!
    const newUser = await this.prisma.profiles.create({
      data: {
        email,
        password: hashedPassword,
        Roles: role.toUpperCase(),
        book_price: 0,
      },
    });

    // Line 43 (Inside signUp)
    return this.generateTokens(newUser.id, newUser.email!, newUser.Roles!);
  }

  async login(email: string, pass: string) {
    const user = await this.prisma.profiles.findUnique({ where: { email } });
    if (!user) {
      throw new UnauthorizedException('The email is Unknown, or not found');
    }

    // Line 52 (Inside login)
    const checkPasswordValid = await verify(user.password!, pass);
    if (!checkPasswordValid) {
      throw new UnauthorizedException('the password is wrong');
    }

    // Line 57 (Inside login)
    return this.generateTokens(user.id, user.email!, user.Roles!);
  }

  // JWT kerja disini
  private generateTokens(userId: string, email: string, role: string) {
    const payload = { sub: userId, email, role };

    return {
      message: 'Authentication successful',
      access_token: this.jwtService.sign(payload),
      user: { id: userId, email, role },
    };
  }
}

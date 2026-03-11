import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { hash, verify } from 'argon2';
import { OAuth2Client } from 'google-auth-library';
import { PrismaService } from 'src/prisma.service';

// total ngulang proses auth: 11

@Injectable()
export class AuthService {
  private googleClient: OAuth2Client;

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {
    this.googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
  }

  async signUp(email: string, pass: string, role: string = 'STUDENT') {
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
        role: role.toUpperCase(),
        book_price: 0,
      },
    });

    // Line 43 (Inside signUp)
    return this.generateTokens(newUser.id, newUser.email!, newUser.role);
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
    return this.generateTokens(user.id, user.email!, user.role);
  }

  async googleLogin(idToken: string, role: string) {
    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken: idToken,
        audience: process.env.GOOGLE_CLIENT_ID,
      });

      // this will extractiong the user info from the ticket
      const payload = ticket.getPayload();
      if (!payload || !payload.email) {
        throw new UnauthorizedException('Invalid Google Token, try again');
      }

      const { email, name, picture } = payload;
      let user = await this.prisma.profiles.findUnique({
        where: { email },
      });

      if (!user) {
        // Create new user with requested role
        user = await this.prisma.profiles.create({
          data: {
            email: email,
            full_name: name,
            avatar_url: picture,
            book_price: 0,
          },
        });
      } else {
        // Update user if info changed (including role)
        const needsUpdate =
          (!user.full_name && name) || (!user.avatar_url && picture);

        if (needsUpdate) {
          user = await this.prisma.profiles.update({
            where: { email },
            data: {
              role: role.toUpperCase(),
              full_name: user.full_name || name,
              avatar_url: user.avatar_url || picture,
            },
          });
        }
      }
      const tokens = this.generateTokens(user.id, user.email!, user.role);

      return {
        ...tokens,
        user: {
          ...tokens.user,
          full_name: user.full_name,
          avatar_url: user.avatar_url,
        },
        message: 'Google Login successful!',
      };
    } catch (e) {
      console.error("There's an error with the google Login Auth: ", e);
      throw new UnauthorizedException('Failed to authenticate with Google');
    }
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
